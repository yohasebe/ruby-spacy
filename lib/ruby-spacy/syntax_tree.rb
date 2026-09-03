# frozen_string_literal: true

module Spacy
  # Converts spaCy parse results into rsyntaxtree bracket notation and renders
  # them with the rsyntaxtree gem. This is an internal implementation module;
  # the public API is {Doc#syntax_tree} and {Span#syntax_tree}.
  #
  # rsyntaxtree is a soft dependency: it is required (>= 2.4.0, for
  # `RSyntaxTree.escape`) on the first call, not at load time.
  module SyntaxTree
    FORMATS = %i[bracket svg png pdf tikz json].freeze
    STYLES = %i[projection chunks].freeze

    # rsyntaxtree drawing defaults chosen for the wide, shallow trees produced
    # here. User-supplied options take precedence (except hyphen, which the
    # escaping depends on).
    RENDER_DEFAULTS = {
      hyphen: "literal",
      polyline: "on",
      tidy: "medium",
      leafstyle: "nothing",
      color: "modern"
    }.freeze

    # Phrase label mapping from the head's POS tag
    PHRASE_LABEL = {
      "NOUN" => "NP", "PROPN" => "NP", "PRON" => "NP", "NUM" => "NP",
      "VERB" => "VP", "AUX" => "VP", "ADP" => "PP", "ADJ" => "AdjP",
      "ADV" => "AdvP", "DET" => "DP", "SCONJ" => "CP", "CCONJ" => "ConjP"
    }.freeze

    ENT_BACKGROUND = "orange"

    class << self
      # @param source [Doc, Span] the document or span to convert
      # @return [String] the bracket notation (format: :bracket), the rendered
      #   output (SVG/TikZ/JSON text, or PNG/PDF binary), depending on format
      def generate(source, format: :bracket, style: :projection, morphology: false,
                   entities: true, punctuation: false, **render_opts)
        ensure_rsyntaxtree!
        format = format.to_sym
        style = style.to_sym
        validate_options!(format, style, render_opts)

        bracket = bracket_for(source, style: style, morphology: morphology,
                              entities: entities, punctuation: punctuation)
        return bracket if format == :bracket

        # Right-to-left scripts are drawn mirrored (leaves run right to left)
        # unless the caller says otherwise. The notation itself is unaffected
        render_opts = { mirror: "on" }.merge(render_opts) if rtl?(source)
        render(bracket, format, render_opts)
      end

      private

      # True when the source's language writes right-to-left. Asked from the
      # pipeline itself (`Defaults.writing_system`) rather than a hardcoded
      # language list, so external pipelines (spacy-stanza, spacy-udpipe) work
      # too. Any failure (e.g. no `Defaults`) falls back to left-to-right;
      # note this also swallows a genuine detection failure, so if an RTL
      # tree ever renders unmirrored, this fallback is the first place to check
      def rtl?(source)
        py_nlp = source.is_a?(Spacy::Span) ? source.doc.py_nlp : source.py_nlp
        direction = Spacy::Builtins.getattr(py_nlp.Defaults, "writing_system")["direction"]
        direction.to_s == "rtl"
      rescue StandardError
        false
      end

      def ensure_rsyntaxtree!
        return if @loaded

        begin
          require "rsyntaxtree"
        rescue LoadError
          raise LoadError, "syntax_tree requires the rsyntaxtree gem (>= 2.4.0): gem install rsyntaxtree"
        end
        unless RSyntaxTree.respond_to?(:escape)
          raise LoadError, "syntax_tree requires rsyntaxtree >= 2.4.0 (found #{RSyntaxTree::VERSION})"
        end
        @loaded = true
      end

      def validate_options!(format, style, render_opts)
        unless FORMATS.include?(format)
          raise ArgumentError, "unknown format: #{format.inspect} (expected one of: #{FORMATS.join(', ')})"
        end
        unless STYLES.include?(style)
          raise ArgumentError, "unknown style: #{style.inspect} (expected one of: #{STYLES.join(', ')})"
        end
        if render_opts.key?(:hyphen)
          raise ArgumentError, "hyphen: cannot be overridden (the notation is escaped for hyphen: :literal)"
        end
        unknown = render_opts.keys.map(&:to_sym) - ::DEFAULT_OPTS.keys
        unless unknown.empty?
          raise ArgumentError,
                "unknown rsyntaxtree option(s): #{unknown.join(', ')} (valid: #{::DEFAULT_OPTS.keys.join(', ')})"
        end
        if format == :bracket && !render_opts.empty?
          raise ArgumentError,
                "drawing options (#{render_opts.keys.join(', ')}) have no effect with format: :bracket"
        end
      end

      def render(bracket, format, render_opts)
        params = RENDER_DEFAULTS.merge(render_opts).merge(data: bracket)
        gen = RSyntaxTree::RSGenerator.new(params)
        case format
        when :svg then gen.draw_svg
        when :json then gen.draw_json
        when :tikz then gen.draw_tikz
        when :png then gen.draw_png.force_encoding(Encoding::BINARY)
        when :pdf then gen.draw_pdf.force_encoding(Encoding::BINARY)
        end
      end

      # Escapes a string for the bracket notation. `as:` follows
      # `RSyntaxTree.escape` (:word for leaf words, :label for entity labels,
      # :cell for AVM cells).
      def escape(text, as:, context: nil)
        RSyntaxTree.escape(text, as: as, hyphen: :literal, apostrophe: :keep)
      rescue ArgumentError => e
        where = context ? " (#{context})" : ""
        raise ArgumentError, "syntax_tree: cannot escape#{where}: #{e.message}"
      end

      def bracket_for(source, style:, morphology:, entities:, punctuation:)
        tokens, root, root_label = tree_scope(source)
        chunks = chunk_spans(source)
        if chunks.nil? && style == :chunks
          raise ArgumentError,
                "noun chunks are not available for this language/model, so style: :chunks cannot be used"
        end
        chunks ||= []
        ents = entities ? ent_map(source) : {}

        case style
        when :chunks
          chunks_bracket(tokens, chunks, ents, morphology: morphology, punctuation: punctuation)
        else
          projection_bracket(root, chunks, ents, root_label: root_label,
                             morphology: morphology, punctuation: punctuation)
        end
      end

      # Returns [tokens, root_token, root_label]. All positions are doc-based
      # (Span#tokens / Token#i are doc-based, which matches chunk and entity
      # offsets).
      def tree_scope(source)
        case source
        when Spacy::Doc
          py_doc = source.py_doc
          unless py_doc.has_annotation("DEP")
            raise ArgumentError, "syntax_tree requires a dependency parse (the pipeline has no parser)"
          end
          if py_doc.has_annotation("SENT_START") && source.sents.size > 1
            raise ArgumentError,
                  "syntax_tree requires a single sentence; " \
                  "use doc.sents.map { |s| s.syntax_tree } for a multi-sentence doc"
          end
          tokens = source.tokens
          # The root is the token that is its own head. Comparing dep strings
          # would tie this to an annotation scheme (spaCy's trained pipelines
          # use "ROOT" while UD-style pipelines such as Stanza use "root")
          root = tokens.find { |t| t.head.i == t.i }
          raise ArgumentError, "syntax_tree: no root token found (no dependency parse)" unless root

          [tokens, root, "S"]
        when Spacy::Span
          unless source.py_span.doc.has_annotation("DEP")
            raise ArgumentError, "syntax_tree requires a dependency parse (the pipeline has no parser)"
          end
          tokens = source.tokens
          raise ArgumentError, "syntax_tree: empty span" if tokens.empty?

          first_i = tokens.first.i
          last_i = tokens.last.i
          roots = tokens.select { |t| t.head.i == t.i || t.head.i < first_i || t.head.i > last_i }
          unless roots.size == 1
            raise ArgumentError,
                  "syntax_tree requires a span with a single root (e.g. a sentence from doc.sents)"
          end
          root = roots.first
          unless root.left_edge.i == first_i && root.right_edge.i == last_i
            raise ArgumentError,
                  "syntax_tree requires a span that is a complete subtree " \
                  "(e.g. a sentence from doc.sents or a noun chunk)"
          end
          is_sentence = source.py_span.sent.start == source.py_span.start &&
                        source.py_span.sent.end == source.py_span.end
          [tokens, root, is_sentence ? "S" : PHRASE_LABEL.fetch(root.pos, "XP")]
        else
          raise ArgumentError, "syntax_tree expects a Spacy::Doc or Spacy::Span"
        end
      end

      # Noun chunk spans as doc-based [start, end) pairs, or nil when the
      # language/model has no noun chunk iterator (spaCy error E894).
      def chunk_spans(source)
        source.noun_chunks.map { |c| [c.py_span.start, c.py_span.end] }
      rescue PyCall::PyError => e
        raise unless e.message.include?("E894")

        nil
      end

      # Entity spans as a doc-based [start, end) => label map
      def ent_map(source)
        source.ents.to_h { |e| [[e.py_span.start, e.py_span.end], e.label] }
      end

      def leaf(token, morphology:)
        word = escape(token.text, as: :word, context: "token #{token.text.inspect}")
        return "[#{token.pos} #{word}]" unless morphology

        rows = ["pos\\t#{escape(token.pos, as: :cell)}"]
        morph = token.morphology(hash: false)
        unless morph.empty?
          morph.split("|").each do |kv|
            k, v = kv.split("=", 2)
            rows << "#{escape(k, as: :cell)}\\t#{escape(v, as: :cell)}"
          end
        end
        "[#(#{rows.join('\n')}#) #{word}]"
      end

      # "%NP" for a bare chunk; "%@orange:NP\nLABEL" for one matching an entity
      def chunk_label(base, ent_label)
        return "%#{base}" unless ent_label

        "%@#{ENT_BACKGROUND}:#{base}\\n#{escape(ent_label, as: :label, context: 'entity label')}"
      end

      # A shallow tree: [S ...] with chunks as [%NP [POS w] ...] and other
      # tokens as plain leaves. Chunks matching an entity get a colored
      # background and a second label line.
      def chunks_bracket(tokens, chunks, ents, morphology:, punctuation:)
        i = 0
        parts = []
        while i < tokens.size
          token = tokens[i]
          chunk = chunks.find { |s, _e| s == token.i }
          if chunk
            s, e = chunk
            chunk_tokens = tokens.select { |t| t.i >= s && t.i < e }
            label = chunk_label("NP", ents[[s, e]])
            parts << "[#{label} #{chunk_tokens.map { |t| leaf(t, morphology: morphology) }.join(' ')}]"
            i += chunk_tokens.size
          else
            parts << leaf(token, morphology: morphology) unless token.pos == "PUNCT" && !punctuation
            i += 1
          end
        end
        "[S #{parts.join(' ')}]"
      end

      # Head projection: each head projects a phrase node over its dependents
      # and itself in word order. A phrase whose span coincides with a noun
      # chunk gets a background; when the chunk containing the head is
      # narrower than the projection (NP -> NP PP), the chunk's tokens are
      # wrapped in an inner [%NP ...]. A single-token chunk (a frequent case
      # for named entities) is wrapped as [%NP leaf] so that the background
      # and entity label are not lost.
      def projection_bracket(token, chunks, ents, root_label:, morphology:, punctuation:)
        kids = token.children.to_a
        kids = kids.reject { |k| k.pos == "PUNCT" } unless punctuation
        if kids.empty?
          node = leaf(token, morphology: morphology)
          single = [token.i, token.i + 1]
          return node unless chunks.include?(single)

          return "[#{chunk_label('NP', ents[single])} #{node}]"
        end

        label = root_label || PHRASE_LABEL.fetch(token.pos, "XP")
        span = [token.left_edge.i, token.right_edge.i + 1]
        label = chunk_label(label, ents[span]) if chunks.include?(span)

        ordered = (kids + [token]).sort_by(&:i)
        render_node = lambda do |t|
          if t.i == token.i
            leaf(t, morphology: morphology)
          else
            projection_bracket(t, chunks, ents, root_label: nil,
                               morphology: morphology, punctuation: punctuation)
          end
        end

        inner = chunks.find { |s, e| (s...e).cover?(token.i) && [s, e] != span }
        if inner
          s, e = inner
          inside, = ordered.partition { |t| (s...e).cover?(t.i) }
          inner_node = "[#{chunk_label('NP', ents[inner])} #{inside.map(&render_node).join(' ')}]"
          parts = ordered.map { |t| inside.include?(t) ? (t.equal?(inside.first) ? inner_node : nil) : render_node.call(t) }
          parts = parts.compact
        else
          parts = ordered.map(&render_node)
        end
        "[#{label} #{parts.join(' ')}]"
      end
    end
  end
end

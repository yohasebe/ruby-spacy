# frozen_string_literal: true

require_relative "ruby-spacy/version"
require 'enumerator'
require 'strscan'
require 'pycall/import'
require 'numpy'
include PyCall::Import

$gpu = true

module Spacy
  class Error < StandardError; end

  def self.generator_to_array(py_generator)
    PyCall::List.(py_generator)
  end

  # class Lexeme
  #   attr_reader :spacy_lexeme_id, :py_lexeme

  #   def initialize(py_lexeme)
  #     options = PyCall::Dict.(options)
  #     PyCall.exec("#{@spacy_lexeme_id}_opts = #{options}")
  #     PyCall.exec("#{@spacy_lexeme_id} = Lexeme(#{nlp.spacy_nlp_id}.vocab, #{orth_id}, **#{spacy_lexeme_id}_opts)")
  #     @py_lexeme = PyCall.eval(@spacy_lexeme_id)
  #   end

  #   def method_missing(name, *args)
  #     @py_lexeme.send(name, *args)
  #   end
  # end

  class Span
    attr_reader :spacy_span_id, :py_span, :doc
    include Enumerable

    alias_method :length, :count
    alias_method :len, :count
    alias_method :size, :count

    def initialize(doc, range, options = {})
      @doc = doc
      @spacy_span_id = "doc_#{doc.object_id}_span_#{range.object_id}"
      options = PyCall::Dict.(options)
      PyCall.exec("#{@spacy_span_id}_opts = #{options}")
      PyCall.exec("#{@spacy_span_id} = Span(#{@doc.spacy_doc_id}, #{range.first}, #{range.first + range.count}, **#{spacy_span_id}_opts)")
      @py_span = PyCall.eval(@spacy_span_id)
    end

    def tokens
      results = []
      PyCall::List.(@py_span).each do |py_token|
        results << Token.new(py_token)
      end
      results
    end

    def each
      PyCall::List.(@py_span).each do |py_token|
        yield Token.new(py_token)
      end
    end

    def noun_chunks
      chunk_array = []
      py_chunks = PyCall::List.(@py_span.noun_chunks)
      py_chunks.each do |py_chunk|
        chunk_array << Spacy::Span.new(@doc, py_chunk.start .. py_chunk.end - 1)
      end
      chunk_array
    end

    def sents
      sentence_array = []
      py_sentences = PyCall::List.(@py_span.sents)
      py_sentences.each do |py_sent|
        sentence_array << Spacy::Span.new(self, py_sent.start .. py_sent.end - 1)
      end
      sentence_array
    end

    def ents
      # so that ents canbe "each"-ed in Ruby
      ent_array = []
      PyCall::List.(@py_span.ents).each do |ent|
        ent_array << ent
      end
      ent_array
    end

    def [](range)
      if range.is_a?(Range)
        py_span = @py_span[range]
        return Spacy::Span.new(@doc, py_span.start .. py_span.end - 1)
      else
        return Spacy::Token.new(@py_span[range])
      end
    end

    def similarity(other)
      PyCall.eval("#{@spacy_span_id}.similarity(#{other.spacy_span_id})")
    end

    def as_doc
      Spacy::Doc.new(@doc.spacy_nlp_id, self.text)
    end

    def conjuncts
      conjunct_array = []
      PyCall::List.(@py_span.conjuncts).each do |py_conjunct|
        conjunct_array << Spacy::Token.new(py_conjunct)
      end
      conjunct_array
    end

    def lefts
      left_array = []
      PyCall::List.(@py_span.lefts).each do |py_left|
        left_array << Spacy::Token.new(py_left)
      end
      left_array
    end

    def rights
      right_array = []
      PyCall::List.(@py_span.rights).each do |py_right|
        right_array << Spacy::Token.new(py_right)
      end
      right_array
    end

    def subtree
      subtree_array = []
      PyCall::List.(@py_span.subtree).each do |py_subtree|
        subtree_array << Spacy::Token.new(py_subtree)
      end
      subtree_array
    end

    def sent
      py_span =@py_span.sent 
      return Spacy::Span.new(@doc, py_span.start .. py_span.end - 1)
    end

    def method_missing(name, *args)
      @py_span.send(name, *args)
    end
  end

  class Token
    attr_reader :py_token, :text

    def initialize(py_token)
      @py_token = py_token
      @text = @py_token.text
    end

    def subtree
      descendant_array = []
      PyCall::List.(@py_token.subtree).each do |descendant|
        descendant_array << descendant
      end
      descendant_array
    end

    def ancestors_list
      ancestor_array = []
      PyCall::List.(@py_token.ancestors).each do |ancestor|
        ancestor_array << ancestor
      end
      ancestor_array
    end

    def children
      child_array = []
      PyCall::List.(@py_token.children).each do |child|
        child_array << child
      end
      child_array
    end

    def lefts
      token_array = []
      PyCall::List.(@py_token.lefts).each do |token|
        token_array << token
      end
      token_array
    end

    def rights
      token_array = []
      PyCall::List.(@py_token.rights).each do |token|
        token_array << token
      end
      token_array
    end

    def to_str
      @text
    end

    def method_missing(name, *args)
      @py_token.send(name, *args)
    end
  end

  class Doc
    attr_reader :spacy_nlp_id, :spacy_doc_id, :py_doc, :text
    include Enumerable

    alias_method :length, :count
    alias_method :len, :count
    alias_method :size, :count

    def initialize(nlp_id, text)
      @text = text
      @spacy_nlp_id = nlp_id
      @spacy_doc_id = "doc_#{text.object_id}"
      quoted = text.gsub('"', '\"')
      PyCall.exec(%Q[text_#{text.object_id} = """#{quoted}"""])
      PyCall.exec("#{@spacy_doc_id} = #{nlp_id}(text_#{text.object_id})")
      @py_doc = PyCall.eval(@spacy_doc_id)
    end

    def retokenize(range, attributes = {})
      py_attrs = PyCall::Dict.(attributes)
      PyCall.exec(<<PY)
with #{@spacy_doc_id}.retokenize() as retokenizer:
    retokenizer.merge(#{@spacy_doc_id}[#{range.first} : #{range.first + range.count}], attrs=#{py_attrs})
PY
      @py_doc = PyCall.eval(@spacy_doc_id)
      return self
    end

    def retokenize_split(pos_in_doc, split_array, head_pos_in_split, ancestor_pos, attributes = {})
      py_attrs = PyCall::Dict.(attributes)
      py_split_array = PyCall::List.(split_array)
      PyCall.exec(<<PY)
with #{@spacy_doc_id}.retokenize() as retokenizer:
    heads = [(#{@spacy_doc_id}[#{pos_in_doc}], #{head_pos_in_split}), #{@spacy_doc_id}[#{ancestor_pos}]]
    attrs = #{py_attrs}
    split_array = #{py_split_array}
    retokenizer.split(#{@spacy_doc_id}[#{pos_in_doc}], split_array, heads=heads, attrs=attrs)
PY
      @py_doc = PyCall.eval(@spacy_doc_id)
      return self
    end

    def to_str
      @text
    end

    def tokens
      results = []
      PyCall::List.(@py_doc).each do |py_token|
        results << Token.new(py_token)
      end
      results
    end

    def each
      PyCall::List.(@py_doc).each do |py_token|
        yield Token.new(py_token)
      end
    end

    def span(range_or_start, optional_end = nil)
      if optional_end
        range = range_or_start ... (range_or_start + optional_end)
      else
        range = range_or_start
      end
      Span.new(self, range)
    end

    def noun_chunks
      chunk_array = []
      py_chunks = PyCall::List.(@py_doc.noun_chunks)
      py_chunks.each do |py_chunk|
        chunk_array << Spacy::Span.new(self, py_chunk.start .. py_chunk.end - 1)
      end
      chunk_array
    end

    def sents
      sentence_array = []
      py_sentences = PyCall::List.(@py_doc.sents)
      py_sentences.each do |py_sent|
        sentence_array << Spacy::Span.new(self, py_sent.start .. py_sent.end - 1)
      end
      sentence_array
    end

    def ents
      # so that ents canbe "each"-ed in Ruby
      ent_array = []
      PyCall::List.(@py_doc.ents).each do |ent|
        ent_array << ent
      end
      ent_array
    end

    def [](range)
      if range.is_a?(Range)
        py_span = @py_doc[range]
        return Spacy::Span.new(self, py_span.start .. py_span.end - 1)
      else
        return Spacy::Token.new(@py_doc[range])
      end
    end

    def similarity(py_doc)
      PyCall.eval("#{@spacy_doc_id}.similarity(#{py_doc.spacy_doc_id})")
    end

    def displacy(style: "dep", compact: false)
      PyCall.eval("displacy.render(#{@spacy_doc_id}, style='#{style}', options={'compact': #{compact.to_s.capitalize}}, jupyter=False)")
    end

    def method_missing(name, *args)
      @py_doc.send(name, *args)
    end
  end

  class Matcher
    attr_reader :spacy_matcher_id, :py_matcher

    def initialize(nlp_id)
      @spacy_matcher_id = "doc_#{nlp_id}_matcher"
      PyCall.exec("#{@spacy_matcher_id} = Matcher(#{nlp_id}.vocab)")
      @py_matcher = PyCall.eval(@spacy_matcher_id)
    end

    def add(text, pattern)
      @py_matcher.add(text, pattern)
    end

    def match(doc)
      str_results = PyCall.eval("#{@spacy_matcher_id}(#{doc.spacy_doc_id})").to_s
      s = StringScanner.new(str_results[1..-2])
      results = []
      while s.scan_until(/(\d+), (\d+), (\d+)/)
        next unless s.matched
        triple = s.matched.split(", ")
        match_id = triple[0].to_i
        range = triple[1].to_i ... triple[2].to_i
        results << [match_id, range]
      end
      results
    end
  end

  class Language
    attr_reader :spacy_nlp_id, :py_nlp

    def initialize(model = "en_core_web_sm")
      @spacy_nlp_id = "nlp_#{model.object_id}"
      PyCall.exec("import spacy; from spacy.tokens import Span; from spacy.matcher import Matcher; from spacy import displacy")
      if $gpu
        PyCall.exec("spacy.prefer_gpu")
      end
      PyCall.exec("#{@spacy_nlp_id} = spacy.load('#{model}')")
      @py_nlp = PyCall.eval(@spacy_nlp_id)
    end

    def read(text)
      Doc.new(@spacy_nlp_id, text)
    end

    def matcher
      Matcher.new(@spacy_nlp_id)
    end

    def vocab_string_lookup(id)
      PyCall.eval("#{@spacy_nlp_id}.vocab.strings[#{id}]")
    end

    def pipe_names
      pipe_array = []
      PyCall::List.(@py_nlp.pipe_names).each do |pipe|
        pipe_array << pipe
      end
      pipe_array
    end

    def tokenizer
      return PyCall.eval("#{@spacy_nlp_id}.tokenizer")
    end

    def get_lexeme(text)
      text = text.gsub("'", "\'")
      py_lexeme = PyCall.eval("#{@spacy_nlp_id}.vocab['#{text}']")
      return py_lexeme
    end

    def most_similar(vector, n)
      vec_array = Numpy.asarray([vector])
      py_result = @py_nlp.vocab.vectors.most_similar(vec_array, n: n)
      key_texts = PyCall.eval("[[str(n), #{@spacy_nlp_id}.vocab[n].text] for n in #{py_result[0][0].tolist()}]")
      keys = key_texts.map{|kt| kt[0]}
      texts = key_texts.map{|kt| kt[1]}
      best_rows = PyCall::List.(py_result[1])[0]
      scores = PyCall::List.(py_result[2])[0]

      results = []
      n.times do |i|
        results << {key: keys[i].to_i, text: texts[i], best_row: best_rows[i], score: scores[i]}
      end

      results
    end

    def method_missing(name, *args)
      @py_nlp.send(name, *args)
    end
  end

end # of module Spacy


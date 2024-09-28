# frozen_string_literal: true

require_relative "ruby-spacy/version"
require "numpy"
require "openai"
require "pycall"
require "strscan"
require "timeout"

begin
  PyCall.init
  _spacy = PyCall.import_module("spacy")
rescue PyCall::PyError => e
  puts "Failed to initialize PyCall or import spacy: #{e.message}"
  puts "Python traceback:"
  puts e.traceback
  raise
end

# This module covers the areas of spaCy functionality for _using_ many varieties of its language models, not for _building_ ones.
module Spacy
  MAX_RETRIAL = 5

  spacy = PyCall.import_module("spacy")
  SpacyVersion = spacy.__version__

  # Python `Language` class
  PyLanguage = spacy.language.Language

  # Python `Doc` class object
  PyDoc = spacy.tokens.Doc

  # Python `Span` class object
  PySpan = spacy.tokens.Span

  # Python `Token` class object
  PyToken = spacy.tokens.Token

  # Python `Matcher` class object
  PyMatcher = spacy.matcher.Matcher

  # Python `displacy` object
  PyDisplacy = PyCall.import_module('spacy.displacy')

  # A utility module method to convert Python's generator object to a Ruby array,
  # mainly used on the items inside the array returned from dependency-related methods
  # such as {Span#rights}, {Span#lefts} and {Span#subtree}.
  def self.generator_to_array(py_generator)
    PyCall::List.call(py_generator)
  end

  @openai_client = nil

  def self.openai_client(access_token:)
    # If @client is already set, just return it. Otherwise, create a new instance.
    @openai_client ||= OpenAI::Client.new(access_token: access_token)
  end

  # Provide an accessor method to get the client (optional)
  def self.client
    @openai_client
  end

  # See also spaCy Python API document for [`Doc`](https://spacy.io/api/doc).
  class Doc
    # @return [Object] a Python `Language` instance accessible via `PyCall`
    attr_reader :py_nlp

    # @return [Object] a Python `Doc` instance accessible via `PyCall`
    attr_reader :py_doc

    # @return [String] a text string of the document
    attr_reader :text

    include Enumerable

    alias length count
    alias len count
    alias size count

    # It is recommended to use {Language#read} method to create a doc. If you need to
    # create one using {Doc#initialize}, there are two method signatures:
    # `Spacy::Doc.new(nlp_id, py_doc: Object)` and `Spacy::Doc.new(nlp_id, text: String)`.
    # @param nlp [Language] an instance of {Language} class
    # @param py_doc [Object] an instance of Python `Doc` class
    # @param text [String] the text string to be analyzed
    def initialize(nlp, py_doc: nil, text: nil, max_retrial: MAX_RETRIAL,
                   retrial: 0)
      @py_nlp = nlp
      @py_doc = py_doc || @py_doc = nlp.call(text)
      @text = @py_doc.text
    rescue StandardError
      retrial += 1
      raise "Error: Failed to construct a Doc object" unless retrial <= max_retrial

      sleep 0.5
      initialize(nlp, py_doc: py_doc, text: text, max_retrial: max_retrial, retrial: retrial)
    end

    # Retokenizes the text merging a span into a single token.
    # @param start_index [Integer] the start position of the span to be retokenized in the document
    # @param end_index [Integer] the end position of the span to be retokenized in the document
    # @param attributes [Hash] attributes to set on the merged token
    def retokenize(start_index, end_index, attributes = {})
      PyCall.with(@py_doc.retokenize) do |retokenizer|
        retokenizer.merge(@py_doc[start_index..end_index], attrs: attributes)
      end
    end

    # Retokenizes the text splitting the specified token.
    # @param pos_in_doc [Integer] the position of the span to be retokenized in the document
    # @param split_array [Array<String>] text strings of the split results
    # @param ancestor_pos [Integer] the position of the immediate ancestor element of the split elements in the document
    # @param attributes [Hash] the attributes of the split elements
    def retokenize_split(pos_in_doc, split_array, head_pos_in_split, ancestor_pos, attributes = {})
      PyCall.with(@py_doc.retokenize) do |retokenizer|
        heads = [[@py_doc[pos_in_doc], head_pos_in_split], @py_doc[ancestor_pos]]
        retokenizer.split(@py_doc[pos_in_doc], split_array, heads: heads, attrs: attributes)
      end
    end

    # String representation of the document.
    # @return [String]
    def to_s
      @text
    end

    # Returns an array of tokens contained in the doc.
    # @return [Array<Token>]
    def tokens
      results = []
      PyCall::List.call(@py_doc).each do |py_token|
        results << Token.new(py_token)
      end
      results
    end

    # Iterates over the elements in the doc yielding a token instance each time.
    def each
      PyCall::List.call(@py_doc).each do |py_token|
        yield Token.new(py_token)
      end
    end

    # Returns a span of the specified range within the doc.
    # The method should be used either of the two ways: `Doc#span(range)` or `Doc#span{start_pos, size_of_span}`.
    # @param range_or_start [Range, Integer] a range object, or, alternatively, an integer that represents the start position of the span
    # @param optional_size [Integer] an integer representing the size of the span
    # @return [Span]
    def span(range_or_start, optional_size = nil)
      if optional_size
        start_index = range_or_start
        temp = tokens[start_index...start_index + optional_size]
      else
        start_index = range_or_start.first
        range = range_or_start
        temp = tokens[range]
      end

      end_index = start_index + temp.size - 1

      Span.new(self, start_index: start_index, end_index: end_index)
    end

    # Returns an array of spans representing noun chunks.
    # @return [Array<Span>]
    def noun_chunks
      chunk_array = []
      py_chunks = PyCall::List.call(@py_doc.noun_chunks)
      py_chunks.each do |py_chunk|
        chunk_array << Span.new(self, start_index: py_chunk.start, end_index: py_chunk.end - 1)
      end
      chunk_array
    end

    # Returns an array of spans each representing a sentence.
    # @return [Array<Span>]
    def sents
      sentence_array = []
      py_sentences = PyCall::List.call(@py_doc.sents)
      py_sentences.each do |py_sent|
        sentence_array << Span.new(self, start_index: py_sent.start, end_index: py_sent.end - 1)
      end
      sentence_array
    end

    # Returns an array of spans each representing a named entity.
    # @return [Array<Span>]
    def ents
      # so that ents canbe "each"-ed in Ruby
      ent_array = []
      PyCall::List.call(@py_doc.ents).each do |ent|
        ent.define_singleton_method :label do
          label_
        end
        ent_array << ent
      end
      ent_array
    end

    # Returns a span if given a range object; or returns a token if given an integer representing a position in the doc.
    # @param range [Range] an ordinary Ruby's range object such as `0..3`, `1...4`, or `3 .. -1`
    def [](range)
      if range.is_a?(Range)
        py_span = @py_doc[range]
        Span.new(self, start_index: py_span.start, end_index: py_span.end - 1)
      else
        Token.new(@py_doc[range])
      end
    end

    # Returns a semantic similarity estimate.
    # @param other [Doc] the other doc to which a similarity estimation is made
    # @return [Float]
    def similarity(other)
      py_doc.similarity(other.py_doc)
    end

    # Visualize the document in one of two styles: "dep" (dependencies) or "ent" (named entities).
    # @param style [String] either `dep` or `ent`
    # @param compact [Boolean] only relevant to the `dep' style
    # @return [String] in the case of `dep`, the output text will be an SVG, whereas in the `ent` style, the output text will be an HTML.
    def displacy(style: "dep", compact: false)
      PyDisplacy.render(py_doc, style: style, options: { compact: compact }, jupyter: false)
    end

    def openai_query(access_token: nil,
                     max_tokens: 1000,
                     temperature: 0.7,
                     model: "gpt-4o-mini",
                     messages: [],
                     prompt: nil)
      if messages.empty?
        messages = [
          { role: "system", content: prompt },
          { role: "user", content: @text }
        ]
      end

      access_token ||= ENV["OPENAI_API_KEY"]
      raise "Error: OPENAI_API_KEY is not set" unless access_token

      begin
        response = Spacy.openai_client(access_token: access_token).chat(
          parameters: {
            model: model,
            messages: messages,
            max_tokens: max_tokens,
            temperature: temperature,
            function_call: "auto",
            stream: false,
            functions: [
              {
                name: "get_tokens",
                description: "Tokenize given text and return a list of tokens with their attributes: surface, lemma, tag, pos (part-of-speech), dep (dependency), ent_type (entity type), and morphology",
                "parameters": {
                  "type": "object",
                  "properties": {
                    "text": {
                      "type": "string",
                      "description": "text to be tokenized"
                    }
                  },
                  "required": ["text"]
                }
              }
            ]
          }
        )

        message = response.dig("choices", 0, "message")

        if message["role"] == "assistant" && message["function_call"]
          messages << message
          function_name = message.dig("function_call", "name")
          _args = JSON.parse(message.dig("function_call", "arguments"))
          case function_name
          when "get_tokens"
            res = tokens.map do |t|
              {
                "surface": t.text,
                "lemma": t.lemma,
                "pos": t.pos,
                "tag": t.tag,
                "dep": t.dep,
                "ent_type": t.ent_type,
                "morphology": t.morphology
              }
            end.to_json
          end
          messages << { role: "system", content: res }
          openai_query(access_token: access_token, max_tokens: max_tokens,
                       temperature: temperature, model: model,
                       messages: messages, prompt: prompt)
        else
          message["content"]
        end
      rescue StandardError => e
        puts "Error: OpenAI API call failed."
        pp e.message
        pp e.backtrace
      end
    end

    def openai_completion(access_token: nil, max_tokens: 1000, temperature: 0.7, model: "gpt-4o-mini")
      messages = [
        { role: "system", content: "Complete the text input by the user." },
        { role: "user", content: @text }
      ]
      access_token ||= ENV["OPENAI_API_KEY"]
      raise "Error: OPENAI_API_KEY is not set" unless access_token

      begin
        response = Spacy.openai_client(access_token: access_token).chat(
          parameters: {
            model: model,
            messages: messages,
            max_tokens: max_tokens,
            temperature: temperature
          }
        )
        response.dig("choices", 0, "message", "content")
      rescue StandardError => e
        puts "Error: OpenAI API call failed."
        pp e.message
        pp e.backtrace
      end
    end

    def openai_embeddings(access_token: nil, model: "text-embedding-ada-002")
      access_token ||= ENV["OPENAI_API_KEY"]
      raise "Error: OPENAI_API_KEY is not set" unless access_token

      begin
        response = Spacy.openai_client(access_token: access_token).embeddings(
          parameters: {
            model: model,
            input: @text
          }
        )
        response.dig("data", 0, "embedding")
      rescue StandardError => e
        puts "Error: OpenAI API call failed."
        pp e.message
        pp e.backtrace
      end
    end

    # Methods defined in Python but not wrapped in ruby-spacy can be called by this dynamic method handling mechanism.
    def method_missing(name, *args)
      @py_doc.send(name, *args)
    end

    def respond_to_missing?(sym, *args)
      sym ? true : super
    end
  end

  # See also spaCy Python API document for [`Language`](https://spacy.io/api/language).
  class Language
    # @return [String] an identifier string that can be used to refer to the Python `Language` object inside `PyCall::exec` or `PyCall::eval`
    attr_reader :spacy_nlp_id

    # @return [Object] a Python `Language` instance accessible via `PyCall`
    attr_reader :py_nlp

    # Creates a language model instance, which is conventionally referred to by a variable named `nlp`.
    # @param model [String] A language model installed in the system
    def initialize(model = "en_core_web_sm", max_retrial: MAX_RETRIAL, retrial: 0, timeout: 60)
      @spacy_nlp_id = "nlp_#{model.object_id}"
      begin
        Timeout.timeout(timeout) do
          PyCall.exec("import spacy; #{@spacy_nlp_id} = spacy.load('#{model}')")
        end
        @py_nlp = PyCall.eval(@spacy_nlp_id)
      rescue Timeout::Error
        raise "PyCall execution timed out after #{timeout} seconds"
      rescue StandardError => e
        retrial += 1
        if retrial <= max_retrial
          sleep 0.5
          retry
        else
          raise "Failed to initialize Spacy after #{max_retrial} attempts: #{e.message}"
        end
      end
    end

    # Reads and analyze the given text.
    # @param text [String] a text to be read and analyzed
    def read(text)
      Doc.new(py_nlp, text: text)
    end

    # Generates a matcher for the current language model.
    # @return [Matcher]
    def matcher
      Matcher.new(@py_nlp)
    end

    # A utility method to lookup a vocabulary item of the given id.
    # @param id [Integer] a vocabulary id
    # @return [Object] a Python `Lexeme` object (https://spacy.io/api/lexeme)
    def vocab_string_lookup(id)
      PyCall.eval("#{@spacy_nlp_id}.vocab.strings[#{id}]")
    end

    # A utility method to list pipeline components.
    # @return [Array<String>] An array of text strings representing pipeline components
    def pipe_names
      pipe_array = []
      PyCall::List.call(@py_nlp.pipe_names).each do |pipe|
        pipe_array << pipe
      end
      pipe_array
    end

    # A utility method to get a Python `Lexeme` object.
    # @param text [String] A text string representing a lexeme
    # @return [Object] Python `Lexeme` object (https://spacy.io/api/lexeme)
    def get_lexeme(text)
      @py_nlp.vocab[text]
    end

    # Returns a ruby lexeme object
    # @param text [String] a text string representing the vocabulary item
    # @return [Lexeme]
    def vocab(text)
      Lexeme.new(@py_nlp.vocab[text])
    end

    # Returns _n_ lexemes having the vector representations that are the most similar to a given vector representation of a word.
    # @param vector [Object] A vector representation of a word (whether existing or non-existing)
    # @return [Array<Hash{:key => Integer, :text => String, :best_rows => Array<Float>, :score => Float}>] An array of hash objects each contains the `key`, `text`, `best_row` and similarity `score` of a lexeme
    def most_similar(vector, num)
      vec_array = Numpy.asarray([vector])
      py_result = @py_nlp.vocab.vectors.most_similar(vec_array, n: num)
      key_texts = PyCall.eval("[[str(num), #{@spacy_nlp_id}.vocab[num].text] for num in #{py_result[0][0].tolist}]")
      keys = key_texts.map { |kt| kt[0] }
      texts = key_texts.map { |kt| kt[1] }
      best_rows = PyCall::List.call(py_result[1])[0]
      scores = PyCall::List.call(py_result[2])[0]

      results = []
      num.times do |i|
        result = { key: keys[i].to_i,
                   text: texts[i],
                   best_row: best_rows[i],
                   score: scores[i] }
        result.each_key do |key|
          result.define_singleton_method(key) { result[key] }
        end
        results << result
      end
      results
    end

    # Utility function to batch process many texts
    # @param texts [String]
    # @param disable [Array<String>]
    # @param batch_size [Integer]
    # @return [Array<Doc>]
    def pipe(texts, disable: [], batch_size: 50)
      docs = []
      PyCall::List.call(@py_nlp.pipe(texts, disable: disable, batch_size: batch_size)).each do |py_doc|
        docs << Doc.new(@py_nlp, py_doc: py_doc)
      end
      docs
    end

    # Methods defined in Python but not wrapped in ruby-spacy can be called by this dynamic method handling mechanism....
    def method_missing(name, *args)
      @py_nlp.send(name, *args)
    end

    def respond_to_missing?(sym, *args)
      sym ? true : super
    end
  end

  # See also spaCy Python API document for [`Matcher`](https://spacy.io/api/matcher).
  class Matcher
    # @return [Object] a Python `Matcher` instance accessible via `PyCall`
    attr_reader :py_matcher

    # Creates a {Matcher} instance
    # @param nlp [Language] an instance of {Language} class
    def initialize(nlp)
      @py_matcher = PyMatcher.call(nlp.vocab)
    end

    # Adds a label string and a text pattern.
    # @param text [String] a label string given to the pattern
    # @param pattern [Array<Array<Hash>>] sequences of text patterns that are alternative to each other
    def add(text, pattern)
      @py_matcher.add(text, pattern)
    end

    # Execute the match.
    # @param doc [Doc] an {Doc} instance
    # @return [Array<Hash{:match_id => Integer, :start_index => Integer, :end_index => Integer}>] the id of the matched pattern, the starting position, and the end position
    def match(doc)
      str_results = @py_matcher.call(doc.py_doc).to_s
      s = StringScanner.new(str_results[1..-2])
      results = []
      while s.scan_until(/(\d+), (\d+), (\d+)/)
        next unless s.matched

        triple = s.matched.split(", ")
        match_id = triple[0].to_i
        start_index = triple[1].to_i
        end_index = triple[2].to_i - 1
        results << { match_id: match_id, start_index: start_index, end_index: end_index }
      end
      results
    end
  end

  # See also spaCy Python API document for [`Span`](https://spacy.io/api/span).
  class Span
    # @return [Object] a Python `Span` instance accessible via `PyCall`
    attr_reader :py_span

    # @return [Doc] the document to which the span belongs
    attr_reader :doc

    include Enumerable

    alias length count
    alias len count
    alias size count

    # It is recommended to use {Doc#span} method to create a span. If you need to
    # create one using {Span#initialize}, there are two method signatures:
    # `Span.new(doc, py_span: Object)` or `Span.new(doc, start_index: Integer, end_index: Integer, options: Hash)`.
    # @param doc [Doc] the document to which this span belongs to
    # @param start_index [Integer] the index of the item starting the span inside a doc
    # @param end_index [Integer] the index of the item ending the span inside a doc
    # @param options [Hash] options (`:label`, `:kb_id`, `:vector`)
    def initialize(doc, py_span: nil, start_index: nil, end_index: nil, options: {})
      @doc = doc
      @py_span = py_span || @py_span = PySpan.call(@doc.py_doc, start_index, end_index + 1, options)
    end

    # Returns an array of tokens contained in the span.
    # @return [Array<Token>]
    def tokens
      results = []
      PyCall::List.call(@py_span).each do |py_token|
        results << Token.new(py_token)
      end
      results
    end

    # Iterates over the elements in the span yielding a token instance each time.
    def each
      PyCall::List.call(@py_span).each do |py_token|
        yield Token.new(py_token)
      end
    end

    # Returns an array of spans of noun chunks.
    # @return [Array<Span>]
    def noun_chunks
      chunk_array = []
      py_chunks = PyCall::List.call(@py_span.noun_chunks)
      py_chunks.each do |py_span|
        chunk_array << Span.new(@doc, py_span: py_span)
      end
      chunk_array
    end

    # Returns the head token
    # @return [Token]
    def root
      Token.new(@py_span.root)
    end

    # Returns an array of spans that represents sentences.
    # @return [Array<Span>]
    def sents
      sentence_array = []
      py_sentences = PyCall::List.call(@py_span.sents)
      py_sentences.each do |py_span|
        sentence_array << Span.new(@doc, py_span: py_span)
      end
      sentence_array
    end

    # Returns an array of spans that represents named entities.
    # @return [Array<Span>]
    def ents
      ent_array = []
      PyCall::List.call(@py_span.ents).each do |py_span|
        ent_array << Span.new(@doc, py_span: py_span)
      end
      ent_array
    end

    # Returns a span that represents the sentence that the given span is part of.
    # @return [Span]
    def sent
      py_span = @py_span.sent
      Span.new(@doc, py_span: py_span)
    end

    # Returns a span if a range object is given or a token if an integer representing the position of the doc is given.
    # @param range [Range] an ordinary Ruby's range object such as `0..3`, `1...4`, or `3 .. -1`
    def [](range)
      if range.is_a?(Range)
        py_span = @py_span[range]
        Span.new(@doc, start_index: py_span.start, end_index: py_span.end - 1)
      else
        Token.new(@py_span[range])
      end
    end

    # Returns a semantic similarity estimate.
    # @param other [Span] the other span to which a similarity estimation is conducted
    # @return [Float]
    def similarity(other)
      py_span.similarity(other.py_span)
    end

    # Creates a document instance from the span
    # @return [Doc]
    def as_doc
      Doc.new(@doc.py_nlp, text: text)
    end

    # Returns tokens conjugated to the root of the span.
    # @return [Array<Token>] an array of tokens
    def conjuncts
      conjunct_array = []
      PyCall::List.call(@py_span.conjuncts).each do |py_conjunct|
        conjunct_array << Token.new(py_conjunct)
      end
      conjunct_array
    end

    # Returns tokens that are to the left of the span, whose heads are within the span.
    # @return [Array<Token>] an array of tokens
    def lefts
      left_array = []
      PyCall::List.call(@py_span.lefts).each do |py_left|
        left_array << Token.new(py_left)
      end
      left_array
    end

    # Returns Tokens that are to the right of the span, whose heads are within the span.
    # @return [Array<Token>] an array of Tokens
    def rights
      right_array = []
      PyCall::List.call(@py_span.rights).each do |py_right|
        right_array << Token.new(py_right)
      end
      right_array
    end

    # Returns Tokens that are within the span and tokens that descend from them.
    # @return [Array<Token>] an array of tokens
    def subtree
      subtree_array = []
      PyCall::List.call(@py_span.subtree).each do |py_subtree|
        subtree_array << Token.new(py_subtree)
      end
      subtree_array
    end

    # Returns the label
    # @return [String]
    def label
      @py_span.label_
    end

    # Methods defined in Python but not wrapped in ruby-spacy can be called by this dynamic method handling mechanism.
    def method_missing(name, *args)
      @py_span.send(name, *args)
    end

    def respond_to_missing?(sym, *args)
      sym ? true : super
    end
  end

  # See also spaCy Python API document for [`Token`](https://spacy.io/api/token).
  class Token
    # @return [Object] a Python `Token` instance accessible via `PyCall`
    attr_reader :py_token

    # @return [String] a string representing the token
    attr_reader :text

    # It is recommended to use {Doc#tokens} or {Span#tokens} methods to create tokens.
    # There is no way to generate a token from scratch but relying on a pre-exising Python `Token` object.
    # @param py_token [Object] Python `Token` object
    def initialize(py_token)
      @py_token = py_token
      @text = @py_token.text
    end

    # Returns the head token
    # @return [Token]
    def head
      Token.new(@py_token.head)
    end

    # Returns the token in question and the tokens that descend from it.
    # @return [Array<Token>] an array of tokens
    def subtree
      descendant_array = []
      PyCall::List.call(@py_token.subtree).each do |descendant|
        descendant_array << Token.new(descendant)
      end
      descendant_array
    end

    # Returns the token's ancestors.
    # @return [Array<Token>] an array of tokens
    def ancestors
      ancestor_array = []
      PyCall::List.call(@py_token.ancestors).each do |ancestor|
        ancestor_array << Token.new(ancestor)
      end
      ancestor_array
    end

    # Returns a sequence of the token's immediate syntactic children.
    # @return [Array<Token>] an array of tokens
    def children
      child_array = []
      PyCall::List.call(@py_token.children).each do |child|
        child_array << Token.new(child)
      end
      child_array
    end

    # The leftward immediate children of the word in the syntactic dependency parse.
    # @return [Array<Token>] an array of tokens
    def lefts
      token_array = []
      PyCall::List.call(@py_token.lefts).each do |token|
        token_array << Token.new(token)
      end
      token_array
    end

    # The rightward immediate children of the word in the syntactic dependency parse.
    # @return [Array<Token>] an array of tokens
    def rights
      token_array = []
      PyCall::List.call(@py_token.rights).each do |token|
        token_array << Token.new(token)
      end
      token_array
    end

    # String representation of the token.
    # @return [String]
    def to_s
      @text
    end

    # Returns a hash or string of morphological information
    # @param hash [Boolean] if true, a hash will be returned instead of a string
    # @return [Hash, String]
    def morphology(hash: true)
      if @py_token.has_morph
        morph_analysis = @py_token.morph
        if hash
          morph_analysis.to_dict
        else
          morph_analysis.to_s
        end
      elsif hash
        {}
      else
        ""
      end
    end

    # Returns the lemma by calling `lemma_' of `@py_token` object
    # @return [String]
    def lemma
      @py_token.lemma_
    end

    # Returns the lowercase form by calling `lower_' of `@py_token` object
    # @return [String]
    def lower
      @py_token.lower_
    end

    # Returns the shape (e.g. "Xxxxx") by calling `shape_' of `@py_token` object
    # @return [String]
    def shape
      @py_token.shape_
    end

    # Returns the pos by calling `pos_' of `@py_token` object
    # @return [String]
    def pos
      @py_token.pos_
    end

    # Returns the fine-grained pos by calling `tag_' of `@py_token` object
    # @return [String]
    def tag
      @py_token.tag_
    end

    # Returns the dependency relation by calling `dep_' of `@py_token` object
    # @return [String]
    def dep
      @py_token.dep_
    end

    # Returns the language by calling `lang_' of `@py_token` object
    # @return [String]
    def lang
      @py_token.lang_
    end

    # Returns the trailing space character if present by calling `whitespace_' of `@py_token` object
    # @return [String]
    def whitespace
      @py_token.whitespace_
    end

    # Returns the named entity type by calling `ent_type_' of `@py_token` object
    # @return [String]
    def ent_type
      @py_token.ent_type_
    end

    # Returns a lexeme object
    # @return [Lexeme]
    def lexeme
      Lexeme.new(@py_token.lex)
    end

    # Methods defined in Python but not wrapped in ruby-spacy can be called by this dynamic method handling mechanism.
    def method_missing(name, *args)
      @py_token.send(name, *args)
    end

    def respond_to_missing?(sym, *args)
      sym ? true : super
    end
  end

  # See also spaCy Python API document for [`Lexeme`](https://spacy.io/api/lexeme).
  class Lexeme
    # @return [Object] a Python `Lexeme` instance accessible via `PyCall`
    attr_reader :py_lexeme

    # @return [String] a string representing the token
    attr_reader :text

    # It is recommended to use {Language#vocab} or {Token#lexeme} methods to create tokens.
    # There is no way to generate a lexeme from scratch but relying on a pre-exising Python {Lexeme} object.
    # @param py_lexeme [Object] Python `Lexeme` object
    def initialize(py_lexeme)
      @py_lexeme = py_lexeme
      @text = @py_lexeme.text
    end

    # String representation of the token.
    # @return [String]
    def to_s
      @text
    end

    # Returns the lowercase form by calling `lower_' of `@py_lexeme` object
    # @return [String]
    def lower
      @py_lexeme.lower_
    end

    # Returns the shape (e.g. "Xxxxx") by calling `shape_' of `@py_lexeme` object
    # @return [String]
    def shape
      @py_lexeme.shape_
    end

    # Returns the language by calling `lang_' of `@py_lexeme` object
    # @return [String]
    def lang
      @py_lexeme.lang_
    end

    # Returns the length-N substring from the start of the word by calling `prefix_' of `@py_lexeme` object
    # @return [String]
    def prefix
      @py_lexeme.prefix_
    end

    # Returns the length-N substring from the end of the word by calling `suffix_' of `@py_lexeme` object
    # @return [String]
    def suffix
      @py_lexeme.suffix_
    end

    # Returns the lexemes's norm, i.e. a normalized form of the lexeme calling `norm_' of `@py_lexeme` object
    # @return [String]
    def norm
      @py_lexeme.norm_
    end

    # Returns a semantic similarity estimate.
    # @param other [Lexeme] the other lexeme to which a similarity estimation is made
    # @return [Float]
    def similarity(other)
      @py_lexeme.similarity(other.py_lexeme)
    end

    # Methods defined in Python but not wrapped in ruby-spacy can be called by this dynamic method handling mechanism.
    def method_missing(name, *args)
      @py_lexeme.send(name, *args)
    end

    def respond_to_missing?(sym, *args)
      sym ? true : super
    end
  end
end

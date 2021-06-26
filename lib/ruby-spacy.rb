# frozen_string_literal: true

require_relative "ruby-spacy/version"
require 'enumerator'
require 'strscan'
require 'pycall/import'
require 'numpy'
include PyCall::Import

# This module covers the areas of spaCy functionality for _using_ many varieties of its language models, not for _building_ ones.
module Spacy
  # A utility module method to convert Python's generator object to a Ruby array, 
  # mainly used on the items inside the array returned from dependency-related methods
  # such as {Span#rights}, {Span#lefts} and {Span#subtree}.
  def self.generator_to_array(py_generator)
    PyCall::List.(py_generator)
  end

  # See also spaCy Python API document for [`Span`](https://spacy.io/api/span).
  class Span

    # @return [String] an identifier string that can be used when referring to the Python object inside `PyCall::exec` or `PyCall::eval`
    attr_reader :spacy_span_id

    # @return [Object] a Python `Span` instance accessible via `PyCall`
    attr_reader :py_span

    # @return [Doc] the document to which the span belongs
    attr_reader :doc

    include Enumerable

    alias_method :length, :count
    alias_method :len, :count
    alias_method :size, :count

    # It is recommended to use {Doc#span} method to create a span. If you need to 
    # create one using {Span#initialize}, either of the two method signatures should be used: `Spacy.new(doc, py_span)` and `Spacy.new(doc, start_index, end_index, options)`.
    # @param doc [Doc] the document to which this span belongs to
    # @param start_index [Integer] the index of the item starting the span inside a doc
    # @param end_index [Integer] the index of the item ending the span inside a doc
    # @param options [Hash] options (`:label`, `:kb_id`, `:vector`)
    def initialize(doc, py_span: nil, start_index: nil, end_index: nil, options: {})
      @doc = doc
      @spacy_span_id = "doc_#{doc.object_id}_span_#{start_index}_#{end_index}"
      if py_span
        @py_span = py_span
      else
        options = PyCall::Dict.(options)
        PyCall.exec("#{@spacy_span_id}_opts = #{options}")
        PyCall.exec("#{@spacy_span_id} = Span(#{@doc.spacy_doc_id}, #{start_index}, #{end_index + 1}, **#{@spacy_span_id}_opts)")
        @py_span = PyCall.eval(@spacy_span_id)
      end
    end

    # Returns an array of tokens contained in the span.
    # @return [Array<Token>]
    def tokens
      results = []
      PyCall::List.(@py_span).each do |py_token|
        results << Token.new(py_token)
      end
      results
    end

    # Iterates over the elements in the span yielding a token instance.
    def each
      PyCall::List.(@py_span).each do |py_token|
        yield Token.new(py_token)
      end
    end

    # Returns an array of spans of noun chunks.
    # @return [Array<Span>]
    def noun_chunks
      chunk_array = []
      py_chunks = PyCall::List.(@py_span.noun_chunks)
      py_chunks.each do |py_span|
        chunk_array << Spacy::Span.new(@doc, py_span: py_span)
      end
      chunk_array
    end

    # Returns an array of spans that represents sentences.
    # @return [Array<Span>]
    def sents
      sentence_array = []
      py_sentences = PyCall::List.(@py_span.sents)
      py_sentences.each do |py_span|
        sentence_array << Spacy::Span.new(@doc, py_span: py_span)
      end
      sentence_array
    end

    # Returns an array of spans that represents named entities.
    # @return [Array<Span>]
    def ents
      ent_array = []
      PyCall::List.(@py_span.ents).each do |py_span|
        # ent_array << ent
        ent_array << Spacy::Span.new(@doc, py_span: py_span)
      end
      ent_array
    end

    # Returns a span that represents the sentence that the given span is part of.
    # @return [Span]
    def sent
      py_span =@py_span.sent 
      return Spacy::Span.new(@doc, py_span: py_span)
    end

    # Returns a span if a range object is given, or a token if an integer representing the position of the doc is given.
    # @param range [Range] an ordinary Ruby's range object such as `0..3`, `1...4`, or `3 .. -1`
    def [](range)
      if range.is_a?(Range)
        py_span = @py_span[range]
        return Spacy::Span.new(@doc, start_index: py_span.start, end_index: py_span.end - 1)
      else
        return Spacy::Token.new(@py_span[range])
      end
    end

    # Returns a semantic similarity estimate.
    # @param other [Span] the other span to which a similarity estimation is conducted
    # @return [Float] 
    def similarity(other)
      PyCall.eval("#{@spacy_span_id}.similarity(#{other.spacy_span_id})")
    end

    # Creates a document instance
    # @return [Doc] 
    def as_doc
      Spacy::Doc.new(@doc.spacy_nlp_id, self.text)
    end

    # Returns Tokens conjugated to the root of the span.
    # @return [Array<Token>] an array of tokens
    def conjuncts
      conjunct_array = []
      PyCall::List.(@py_span.conjuncts).each do |py_conjunct|
        conjunct_array << Spacy::Token.new(py_conjunct)
      end
      conjunct_array
    end

    # Returns Tokens that are to the left of the span, whose heads are within the span.
    # @return [Array<Token>] an array of tokens  
    def lefts
      left_array = []
      PyCall::List.(@py_span.lefts).each do |py_left|
        left_array << Spacy::Token.new(py_left)
      end
      left_array
    end

    # Returns Tokens that are to the right of the span, whose heads are within the span.
    # @return [Array<Token>] an array of Tokens  
    def rights
      right_array = []
      PyCall::List.(@py_span.rights).each do |py_right|
        right_array << Spacy::Token.new(py_right)
      end
      right_array
    end

    # Returns Tokens that are within the span and tokens that descend from them.
    # @return [Array<Token>] an array of tokens  
    def subtree
      subtree_array = []
      PyCall::List.(@py_span.subtree).each do |py_subtree|
        subtree_array << Spacy::Token.new(py_subtree)
      end
      subtree_array
    end

    # Methods defined in Python but not wrapped in ruby-spacy can be called by this dynamic method handling mechanism.
    def method_missing(name, *args)
      @py_span.send(name, *args)
    end
  end

  # See also spaCy Python API document for [`Token`](https://spacy.io/api/token).
  class Token

    # @return [Object] a Python `Token` instance accessible via `PyCall`
    attr_reader :py_token

    # @return [String] a string representing the token
    attr_reader :text

    # It is recommended to use {Doc#tokens} or {Span#tokens} methods to create tokens. There is no way to generate a token from scratch but relying on a pre-exising Python {Token} object.
    # @param py_token [Object] Python `Token` object
    def initialize(py_token)
      @py_token = py_token
      @text = @py_token.text
    end

    # Returns the token in question and the tokens that descend from it.
    # @return [Array<Object>] an (Ruby) array of Python `Token` objects  
    def subtree
      descendant_array = []
      PyCall::List.(@py_token.subtree).each do |descendant|
        descendant_array << descendant
      end
      descendant_array
    end

    # Returns the token's ancestors.
    # @return [Array<Object>] an (Ruby) array of Python `Token` objects 
    def ancestors
      ancestor_array = []
      PyCall::List.(@py_token.ancestors).each do |ancestor|
        ancestor_array << ancestor
      end
      ancestor_array
    end

    # Returns a sequence of the token's immediate syntactic children.
    # @return [Array<Object>] an (Ruby) array of Python `Token` objects  
    def children
      child_array = []
      PyCall::List.(@py_token.children).each do |child|
        child_array << child
      end
      child_array
    end

    # The leftward immediate children of the word in the syntactic dependency parse.
    # @return [Array<Object>] an (Ruby) array of Python `Token` objects  
    def lefts
      token_array = []
      PyCall::List.(@py_token.lefts).each do |token|
        token_array << token
      end
      token_array
    end

    # The rightward immediate children of the word in the syntactic dependency parse.
    # @return [Array<Object>] an (Ruby) array of Python `Token` objects  
    def rights
      token_array = []
      PyCall::List.(@py_token.rights).each do |token|
        token_array << token
      end
      token_array
    end

    # String representation of the token.
    # @return [String] 
    def to_str
      @text
    end

    # Methods defined in Python but not wrapped in ruby-spacy can be called by this dynamic method handling mechanism.
    def method_missing(name, *args)
      @py_token.send(name, *args)
    end
  end

  # See also spaCy Python API document for [`Doc`](https://spacy.io/api/doc).
  class Doc

    # @return [String] an identifier string that can be used when referring to the Python object inside `PyCall::exec` or `PyCall::eval`
    attr_reader :spacy_nlp_id

    # @return [String] an identifier string that can be used when referring to the Python object inside `PyCall::exec` or `PyCall::eval`
    attr_reader :spacy_doc_id

    # @return [Object] a Python `Doc` instance accessible via `PyCall`
    attr_reader :py_doc

    # @return [String] a text string of the document
    attr_reader :text

    include Enumerable

    alias_method :length, :count
    alias_method :len, :count
    alias_method :size, :count

    # Creates a new instance of {Doc}.
    # @param nlp_id [String] The id string of the `nlp`, an instance of {Language} class
    # @param text [String] The text string to be analyzed
    def initialize(nlp_id, text)
      @text = text
      @spacy_nlp_id = nlp_id
      @spacy_doc_id = "doc_#{text.object_id}"
      quoted = text.gsub('"', '\"')
      PyCall.exec(%Q[text_#{text.object_id} = """#{quoted}"""])
      PyCall.exec("#{@spacy_doc_id} = #{nlp_id}(text_#{text.object_id})")
      @py_doc = PyCall.eval(@spacy_doc_id)
    end


    # Retokenizes the text merging a span into a single token.
    # @param start_index [Integer] The start position of the span to be retokenized in the document
    # @param end_index [Integer] The end position of the span to be retokenized in the document
    # @param attributes [Hash] Attributes to set on the merged token
    def retokenize(start_index, end_index, attributes = {})
      py_attrs = PyCall::Dict.(attributes)
      PyCall.exec(<<PY)
with #{@spacy_doc_id}.retokenize() as retokenizer:
    retokenizer.merge(#{@spacy_doc_id}[#{start_index} : #{end_index + 1}], attrs=#{py_attrs})
PY
      @py_doc = PyCall.eval(@spacy_doc_id)
    end

    # Retokenizes the text splitting the specified token.
    # @param pos_in_doc [Integer] The position of the span to be retokenized in the document
    # @param split_array [Array<String>] text strings of the split results 
    # @param ancestor_pos [Integer] The position of the immediate ancestor element of the split elements in the document
    # @param attributes [Hash] The attributes of the split elements
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
    end

    # String representation of the token.
    # @return [String] 
    def to_str
      @text
    end

    # Returns an array of tokens contained in the doc.
    # @return [Array<Token>]
    def tokens
      results = []
      PyCall::List.(@py_doc).each do |py_token|
        results << Token.new(py_token)
      end
      results
    end

    # Iterates over the elements in the doc yielding a token instance.
    def each
      PyCall::List.(@py_doc).each do |py_token|
        yield Token.new(py_token)
      end
    end

    # Returns a span of the specified range within the doc. 
    # The method should be used either of the two ways: `Doc#span(range)` or `Doc#span{start_pos, size_of_span}`.
    # @param range_or_start [Range, Integer] A range object, or, alternatively, an integer that represents the start position of the span
    # @param optional_size [Integer] An integer representing the size of the span
    # @return [Span]
    def span(range_or_start, optional_size = nil)
      if optional_size
        start_index = range_or_start
        temp = tokens[start_index ... start_index + optional_size]
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
      py_chunks = PyCall::List.(@py_doc.noun_chunks)
      py_chunks.each do |py_chunk|
        chunk_array << Span.new(self, start_index: py_chunk.start, end_index: py_chunk.end - 1)
      end
      chunk_array
    end

    # Returns an array of spans representing sentences.
    # @return [Array<Span>]
    def sents
      sentence_array = []
      py_sentences = PyCall::List.(@py_doc.sents)
      py_sentences.each do |py_sent|
        sentence_array << Span.new(self, start_index: py_sent.start, end_index: py_sent.end - 1)
      end
      sentence_array
    end

    # Returns an array of spans representing named entities.
    # @return [Array<Span>]
    def ents
      # so that ents canbe "each"-ed in Ruby
      ent_array = []
      PyCall::List.(@py_doc.ents).each do |ent|
        ent_array << ent
      end
      ent_array
    end

    # Returns a span if given a range object; returns a token if given an integer representing a position in the doc.
    # @param range [Range] an ordinary Ruby's range object such as `0..3`, `1...4`, or `3 .. -1`
    def [](range)
      if range.is_a?(Range)
        py_span = @py_doc[range]
        return Span.new(self, start_index: py_span.start, end_index: py_span.end - 1)
      else
        return Token.new(@py_doc[range])
      end
    end

    # Returns a semantic similarity estimate.
    # @param other [Doc] the other doc to which a similarity estimation is made
    # @return [Float] 
    def similarity(other)
      PyCall.eval("#{@spacy_doc_id}.similarity(#{other.spacy_doc_id})")
    end

    # Visualize the document in one of two styles: dep (dependencies) or ent (named entities).
    # @param style [String] Either `dep` or `ent`
    # @param compact [Boolean] Only relevant to the `dep' style
    # @return [String] In the case of `dep`, the output text is an SVG while in the `ent` style, the output text is an HTML.
    def displacy(style: "dep", compact: false)
      PyCall.eval("displacy.render(#{@spacy_doc_id}, style='#{style}', options={'compact': #{compact.to_s.capitalize}}, jupyter=False)")
    end

    # Methods defined in Python but not wrapped in ruby-spacy can be called by this dynamic method handling mechanism.
    def method_missing(name, *args)
      @py_doc.send(name, *args)
    end
  end

  # See also spaCy Python API document for [`Matcher`](https://spacy.io/api/matcher).
  class Matcher

    # @return [String] an identifier string that can be used when referring to the Python object inside `PyCall::exec` or `PyCall::eval`
    attr_reader :spacy_matcher_id

    # @return [Object] a Python `Matcher` instance accessible via `PyCall`
    attr_reader :py_matcher

    # Creates a {Matcher} instance
    # @param nlp_id [String] The id string of the `nlp`, an instance of {Language} class
    def initialize(nlp_id)
      @spacy_matcher_id = "doc_#{nlp_id}_matcher"
      PyCall.exec("#{@spacy_matcher_id} = Matcher(#{nlp_id}.vocab)")
      @py_matcher = PyCall.eval(@spacy_matcher_id)
    end

    # Adds a label string and a text pattern.
    # @param text [String] a label string given to the pattern
    # @param pattern [Array<Array<Hash>>] alternative sequences of text patterns 
    def add(text, pattern)
      @py_matcher.add(text, pattern)
    end

    # Execute the match.
    # @param doc [Doc] An {Doc} instance
    # @return [Array<Hash{:match_id => Integer, :start_index => Integer, :end_index => Integer}>] The id of the matched pattern, the starting position, and the end position
    def match(doc)
      str_results = PyCall.eval("#{@spacy_matcher_id}(#{doc.spacy_doc_id})").to_s
      s = StringScanner.new(str_results[1..-2])
      results = []
      while s.scan_until(/(\d+), (\d+), (\d+)/)
        next unless s.matched
        triple = s.matched.split(", ")
        match_id = triple[0].to_i
        start_index = triple[1].to_i
        end_index = triple[2].to_i - 1
        results << {match_id: match_id, start_index: start_index, end_index: end_index}
      end
      results
    end
  end

  # See also spaCy Python API document for [`Language`](https://spacy.io/api/language).
  class Language

    # @return [String] an identifier string that can be used when referring to the Python object inside `PyCall::exec` or `PyCall::eval`
    attr_reader :spacy_nlp_id

    # @return [Object] a Python `Language` instance accessible via `PyCall`
    attr_reader :py_nlp

    # Creates a language model instance, which is conventionally referred to by a variable named `nlp`.
    # @param model [String] A language model installed in the system
    def initialize(model = "en_core_web_sm")
      @spacy_nlp_id = "nlp_#{model.object_id}"
      PyCall.exec("import spacy; from spacy.tokens import Span; from spacy.matcher import Matcher; from spacy import displacy")
      PyCall.exec("#{@spacy_nlp_id} = spacy.load('#{model}')")
      @py_nlp = PyCall.eval(@spacy_nlp_id)
    end

    # Reads and analyze the given text.
    # @param text [String] A text to be read and analyzed
    def read(text)
      Doc.new(@spacy_nlp_id, text)
    end

    # Generate a matcher associated with the current language model.
    # @return [Matcher]
    def matcher
      Matcher.new(@spacy_nlp_id)
    end

    # A utility method to lookup a vocabulary item of the given id.
    # @param id [Integer] A vocabulary id
    # @return [Object] A Python `Lexeme` object
    def vocab_string_lookup(id)
      PyCall.eval("#{@spacy_nlp_id}.vocab.strings[#{id}]")
    end

    # A utility method to list pipeline components.
    # @return [Array<String>] An array of text strings representing pipeline components
    def pipe_names
      pipe_array = []
      PyCall::List.(@py_nlp.pipe_names).each do |pipe|
        pipe_array << pipe
      end
      pipe_array
    end

    # A utility method to get the tokenizer Python object.
    # @return [Object] Python `Tokenizer` object
    def tokenizer
      return PyCall.eval("#{@spacy_nlp_id}.tokenizer")
    end

    # A utility method to get a Python `Lexeme` object.
    # @param text [String] A text string representing a lexeme
    # @return [Object] Python `Tokenizer` object
    def get_lexeme(text)
      text = text.gsub("'", "\'")
      py_lexeme = PyCall.eval("#{@spacy_nlp_id}.vocab['#{text}']")
      return py_lexeme
    end

    # Returns _n_ lexemes having the vector representations that are the most similar to a given vector representation of a word.
    # @param vector [Object] A vector representation of a word (whether existing or non-existing)
    # @return [Array<Hash{:key => Integer, :text => String, :best_rows => Array<Float>, :score => Float}>] An array of hash objects each contains the `key`, `text`, `best_row` and similarity `score` of a lexeme
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

    # Methods defined in Python but not wrapped in ruby-spacy can be called by this dynamic method handling mechanism....
    def method_missing(name, *args)
      @py_nlp.send(name, *args)
    end
  end

end


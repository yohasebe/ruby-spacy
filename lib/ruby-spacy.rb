# frozen_string_literal: true

require_relative "ruby-spacy/version"
require_relative "ruby-spacy/llm_client_base"
require_relative "ruby-spacy/openai_client"
require_relative "ruby-spacy/anthropic_client"
require_relative "ruby-spacy/openai_helper"
require_relative "ruby-spacy/anthropic_helper"
require "numpy"
require "pycall"
require "timeout"
require "json"
require "base64"

# This module covers the areas of spaCy functionality for _using_ many varieties of its language models, not for _building_ ones.
module Spacy
  MAX_RETRIAL = 5

  begin
    PyCall.init
    spacy = PyCall.import_module("spacy")
  rescue PyCall::PyError => e
    puts "Failed to initialize PyCall or import spacy: #{e.message}"
    puts "Python traceback:"
    puts e.traceback
    raise
  end

  Builtins = PyCall.import_module("builtins")
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

  # Python `PhraseMatcher` class object
  PyPhraseMatcher = spacy.matcher.PhraseMatcher

  # Python `displacy` object
  PyDisplacy = PyCall.import_module('spacy.displacy')

  # A utility module method to convert Python's generator object to a Ruby array,
  # mainly used on the items inside the array returned from dependency-related methods
  # such as {Span#rights}, {Span#lefts} and {Span#subtree}.
  def self.generator_to_array(py_generator)
    PyCall::List.call(py_generator)
  end

  # Checks if a Python object has a given attribute using builtins.hasattr.
  # Falls back to true if the check itself fails (e.g. due to PyCall issues).
  # @param py_obj [Object] a Python object
  # @param attr [String, Symbol] the attribute name to check
  # @return [Boolean]
  def self.py_hasattr?(py_obj, attr)
    Builtins.hasattr(py_obj, attr.to_s)
  rescue StandardError
    true
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
    def initialize(nlp, py_doc: nil, text: nil, max_retrial: MAX_RETRIAL)
      @py_nlp = nlp
      retrial = 0
      begin
        @py_doc = py_doc || nlp.call(text)
        @text = @py_doc.text
      rescue StandardError
        retrial += 1
        raise "Error: Failed to construct a Doc object" unless retrial <= max_retrial

        sleep 0.5
        retry
      end
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
      PyCall::List.call(@py_doc).map { |py_token| Token.new(py_token) }
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
      doc_len = PyCall.len(@py_doc)

      if optional_size
        start_index = range_or_start
        start_index += doc_len if start_index < 0
        end_index = start_index + optional_size - 1
      else
        range = range_or_start
        start_index = range.first
        start_index += doc_len if start_index < 0
        end_val = range.end
        if end_val.nil?
          end_index = doc_len - 1
        else
          end_val += doc_len if end_val < 0
          end_index = range.exclude_end? ? end_val - 1 : end_val
        end
      end

      Span.new(self, start_index: start_index, end_index: end_index)
    end

    # Returns an array of spans representing noun chunks.
    # @return [Array<Span>]
    def noun_chunks
      PyCall::List.call(@py_doc.noun_chunks).map do |py_chunk|
        Span.new(self, start_index: py_chunk.start, end_index: py_chunk.end - 1)
      end
    end

    # Returns an array of spans each representing a sentence.
    # @return [Array<Span>]
    def sents
      PyCall::List.call(@py_doc.sents).map do |py_sent|
        Span.new(self, start_index: py_sent.start, end_index: py_sent.end - 1)
      end
    end

    # Returns an array of spans each representing a named entity.
    # @return [Array<Span>]
    def ents
      PyCall::List.call(@py_doc.ents).map do |py_span|
        Span.new(self, py_span: py_span)
      end
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

    # Serializes the doc to a binary string.
    # The binary data includes all annotations (tokens, entities, etc.) and can be
    # used to restore the doc later without re-processing.
    # @return [String] binary representation of the doc
    # @example Save doc to file
    #   doc = nlp.read("Hello world")
    #   File.binwrite("doc.bin", doc.to_bytes)
    def to_bytes
      @py_doc.to_bytes.force_encoding(Encoding::BINARY)
    end

    # Restores a doc from binary data created by {#to_bytes}.
    # This is useful for caching processed documents to avoid re-processing.
    # @param byte_string [String] binary data from {#to_bytes}
    # @return [Doc] the restored doc
    # @example Load doc from file
    #   bytes = File.binread("doc.bin")
    #   doc = Spacy::Doc.from_bytes(nlp, bytes)
    def self.from_bytes(nlp, byte_string)
      b64 = Base64.strict_encode64(byte_string)
      py_bytes = PyCall.eval("__import__('base64').b64decode('#{b64}')")
      py_doc = nlp.py_nlp.call("").from_bytes(py_bytes)
      new(nlp.py_nlp, py_doc: py_doc)
    end

    # Visualize the document in one of two styles: "dep" (dependencies) or "ent" (named entities).
    # @param style [String] either `dep` or `ent`
    # @param compact [Boolean] only relevant to the `dep' style
    # @return [String] in the case of `dep`, the output text will be an SVG, whereas in the `ent` style, the output text will be an HTML.
    def displacy(style: "dep", compact: false)
      PyDisplacy.render(py_doc, style: style, options: { compact: compact }, jupyter: false)
    end

    # Generates a JSON string summarizing the linguistic analysis of the document.
    # Designed to be passed as context to an LLM (e.g., via {OpenAIHelper#chat}).
    #
    # @param sections [Array<Symbol>] which sections to include
    #   (:text, :tokens, :entities, :noun_chunks, :sentences)
    # @param token_attributes [Array<Symbol>] which token attributes to include
    #   (:text, :lemma, :pos, :tag, :dep, :head, :ent_type, :morphology)
    # @return [String] a JSON string of the linguistic summary
    def linguistic_summary(sections: [:text, :tokens, :entities, :noun_chunks],
                           token_attributes: [:text, :lemma, :pos, :dep, :head])
      result = {}

      sections.each do |section|
        case section
        when :text
          result[:text] = @text
        when :tokens
          result[:tokens] = tokens.map do |token|
            token_hash = {}
            token_attributes.each do |attr|
              case attr
              when :head
                token_hash[:head] = token.head.text
              when :morphology
                # Use string form and parse to ensure a plain Ruby Hash for JSON serialization
                morph_str = token.morphology(hash: false)
                token_hash[:morphology] = if morph_str.empty?
                                            {}
                                          else
                                            morph_str.split("|").each_with_object({}) do |pair, h|
                                              k, v = pair.split("=", 2)
                                              h[k] = v
                                            end
                                          end
              else
                token_hash[attr] = token.send(attr)
              end
            end
            token_hash
          end
        when :entities
          ent_list = ents
          result[:entities] = ent_list.map do |ent|
            { text: ent.text, label: ent.label }
          end
        when :noun_chunks
          result[:noun_chunks] = noun_chunks.map do |chunk|
            { text: chunk.text, root: chunk.root.text }
          end
        when :sentences
          result[:sentences] = sents.map(&:text)
        end
      end

      result.to_json
    end

    # Sends a query to OpenAI's chat completion API with optional tool support.
    # The get_tokens tool allows the model to request token-level linguistic analysis.
    #
    # @param access_token [String, nil] OpenAI API key (defaults to OPENAI_API_KEY env var)
    # @param max_completion_tokens [Integer] Maximum tokens in the response
    # @param max_tokens [Integer] Alias for max_completion_tokens (deprecated, for backward compatibility)
    # @param temperature [Float, nil] Sampling temperature (omitted from requests
    #   when nil; models that reject it are retried without it)
    # @param model [String] The model to use (default: gpt-5-mini)
    # @param messages [Array<Hash>] Conversation history (for recursive tool calls). Note: this array is modified in place when tool calls occur.
    # @param prompt [String, nil] System prompt for the query
    # @return [String, nil] The model's response content
    def openai_query(access_token: nil,
                     max_completion_tokens: nil,
                     max_tokens: nil,
                     temperature: nil,
                     model: OpenAIClient::DEFAULT_MODEL,
                     messages: [],
                     prompt: nil,
                     response_format: nil,
                     max_tool_call_depth: 5,
                     _tool_call_depth: 0)
      # Support both max_completion_tokens and max_tokens for backward compatibility
      max_completion_tokens ||= max_tokens || 1000
      if messages.empty?
        messages = [
          { role: "system", content: prompt },
          { role: "user", content: @text }
        ]
      end

      client = openai_client(access_token)

      # Tool definition for token analysis (GPT-5 tools API format)
      tools = nil
      tool_choice = nil
      if _tool_call_depth < max_tool_call_depth
        tools = [
          {
            type: "function",
            function: {
              name: "get_tokens",
              description: "Tokenize given text and return a list of tokens with their attributes: surface, lemma, tag, pos (part-of-speech), dep (dependency), ent_type (entity type), and morphology",
              parameters: {
                type: "object",
                properties: {
                  text: {
                    type: "string",
                    description: "text to be tokenized"
                  }
                },
                required: ["text"]
              }
            }
          }
        ]
        tool_choice = "auto"
      end

      response = client.chat(
        model: model,
        messages: messages,
        max_completion_tokens: max_completion_tokens,
        temperature: temperature,
        tools: tools,
        tool_choice: tool_choice,
        response_format: response_format
      )

      message = response.dig("choices", 0, "message")

      # Handle tool calls (GPT-5 format)
      if message["tool_calls"] && !message["tool_calls"].empty?
        messages << message

        message["tool_calls"].each do |tool_call|
          function_name = tool_call.dig("function", "name")
          tool_call_id = tool_call["id"]

          case function_name
          when "get_tokens"
            result = tokens.map do |t|
              {
                surface: t.text,
                lemma: t.lemma,
                pos: t.pos,
                tag: t.tag,
                dep: t.dep,
                ent_type: t.ent_type,
                morphology: t.morphology
              }
            end.to_json

            messages << {
              role: "tool",
              tool_call_id: tool_call_id,
              content: result
            }
          end
        end

        # Recursive call to get final response after tool execution
        openai_query(
          access_token: access_token,
          max_completion_tokens: max_completion_tokens,
          temperature: temperature,
          model: model,
          messages: messages,
          prompt: prompt,
          response_format: response_format,
          max_tool_call_depth: max_tool_call_depth,
          _tool_call_depth: _tool_call_depth + 1
        )
      else
        message["content"]
      end
    rescue OpenAIClient::APIError => e
      warn "Error: OpenAI API call failed - #{e.message}"
      nil
    end

    # Sends a text completion request to OpenAI's chat API.
    #
    # @param access_token [String, nil] OpenAI API key (defaults to OPENAI_API_KEY env var)
    # @param max_completion_tokens [Integer] Maximum tokens in the response
    # @param max_tokens [Integer] Alias for max_completion_tokens (deprecated, for backward compatibility)
    # @param temperature [Float, nil] Sampling temperature (omitted from requests
    #   when nil; models that reject it are retried without it)
    # @param model [String] The model to use (default: gpt-5-mini)
    # @return [String, nil] The completed text
    def openai_completion(access_token: nil, max_completion_tokens: nil, max_tokens: nil, temperature: nil, model: OpenAIClient::DEFAULT_MODEL)
      # Support both max_completion_tokens and max_tokens for backward compatibility
      max_completion_tokens ||= max_tokens || 1000

      messages = [
        { role: "system", content: "Complete the text input by the user." },
        { role: "user", content: @text }
      ]

      client = openai_client(access_token)
      response = client.chat(
        model: model,
        messages: messages,
        max_completion_tokens: max_completion_tokens,
        temperature: temperature
      )
      response.dig("choices", 0, "message", "content")
    rescue OpenAIClient::APIError => e
      warn "Error: OpenAI API call failed - #{e.message}"
      nil
    end

    # Generates text embeddings using OpenAI's embeddings API.
    #
    # @param access_token [String, nil] OpenAI API key (defaults to OPENAI_API_KEY env var)
    # @param model [String] The embeddings model (default: text-embedding-3-small)
    # @param dimensions [Integer, nil] The number of dimensions for the output embeddings (nil uses model default)
    # @return [Array<Float>, nil] The embedding vector
    def openai_embeddings(access_token: nil, model: OpenAIClient::DEFAULT_EMBEDDINGS_MODEL, dimensions: nil)
      client = openai_client(access_token)
      response = client.embeddings(model: model, input: @text, dimensions: dimensions)
      response.dig("data", 0, "embedding")
    rescue OpenAIClient::APIError => e
      warn "Error: OpenAI API call failed - #{e.message}"
      nil
    end

    private

    def openai_client(access_token)
      access_token ||= ENV["OPENAI_API_KEY"]
      raise "Error: OPENAI_API_KEY is not set" unless access_token

      @openai_clients ||= {}
      @openai_clients[access_token] ||= OpenAIClient.new(access_token: access_token)
    end

    public

    # Methods defined in Python but not wrapped in ruby-spacy can be called by this dynamic method handling mechanism.
    def method_missing(name, *args)
      @py_doc.send(name, *args)
    end

    def respond_to_missing?(sym, include_private = false)
      Spacy.py_hasattr?(@py_doc, sym) || super
    end

    def instance_variables_to_inspect
      [:@text]
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
    def initialize(model = "en_core_web_sm", max_retrial: MAX_RETRIAL, timeout: 60)
      unless model.to_s.match?(/\A[a-zA-Z0-9_\-\.\/]+\z/)
        raise ArgumentError, "Invalid model name: #{model.inspect}"
      end

      @spacy_nlp_id = "nlp_#{model.object_id}"
      retrial = 0
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

    # Generates a phrase matcher for the current language model.
    # PhraseMatcher is more efficient than {Matcher} for matching large terminology lists.
    # @param attr [String] the token attribute to match on (default: "ORTH").
    #   Use "LOWER" for case-insensitive matching.
    # @return [PhraseMatcher]
    # @example
    #   matcher = nlp.phrase_matcher(attr: "LOWER")
    #   matcher.add("PRODUCT", ["iPhone", "MacBook Pro"])
    def phrase_matcher(attr: "ORTH")
      PhraseMatcher.new(self, attr: attr)
    end

    # A utility method to lookup a vocabulary item of the given id.
    # @param id [Integer] a vocabulary id
    # @return [Object] a Python `Lexeme` object (https://spacy.io/api/lexeme)
    def vocab_string_lookup(id)
      PyCall.eval("#{@spacy_nlp_id}.vocab.strings[#{Integer(id)}]")
    end

    # A utility method to list pipeline components.
    # @return [Array<String>] An array of text strings representing pipeline components
    def pipe_names
      PyCall::List.call(@py_nlp.pipe_names).to_a
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
      PyCall::List.call(@py_nlp.pipe(texts, disable: disable, batch_size: batch_size)).map do |py_doc|
        Doc.new(@py_nlp, py_doc: py_doc)
      end
    end

    # Yields a provider-specific LLM helper for making API calls within a block.
    # The helper is configured once and reused for all calls within the block,
    # making it efficient for batch processing with {#pipe}.
    #
    # Providers:
    # - +:openai+ — OpenAI API (or any OpenAI-compatible endpoint via +base_url:+).
    #   Yields an {OpenAIHelper}.
    # - +:anthropic+ — Anthropic (Claude) Messages API. Yields an {AnthropicHelper}.
    # - +:ollama+ — shortcut for a local Ollama server
    #   (+base_url: "http://localhost:11434/v1"+, no API key needed).
    #   Yields an {OpenAIHelper}.
    #
    # @param provider [Symbol] :openai (default), :anthropic, or :ollama
    # @param opts [Hash] helper options (access_token:, model:, max_tokens:,
    #   temperature:, base_url:, ...) — see {OpenAIHelper#initialize} and
    #   {AnthropicHelper#initialize}
    # @yield [OpenAIHelper, AnthropicHelper] the helper instance for making API calls
    # @return [Object] the block's return value
    # @example Claude
    #   nlp.with_llm(provider: :anthropic) do |ai|
    #     ai.chat(system: "Analyze.", user: doc.linguistic_summary)
    #   end
    # @example Local model via Ollama
    #   nlp.with_llm(provider: :ollama, model: "llama3.2") do |ai|
    #     ai.chat(user: "Say hello.")
    #   end
    def with_llm(provider: :openai, **opts)
      helper = case provider.to_sym
               when :openai
                 OpenAIHelper.new(**opts)
               when :anthropic
                 AnthropicHelper.new(**opts)
               when :ollama
                 OpenAIHelper.new(**{ base_url: "http://localhost:11434/v1",
                                      access_token: "ollama" }.merge(opts))
               else
                 raise ArgumentError, "Unknown LLM provider: #{provider} (use :openai, :anthropic, or :ollama)"
               end
      yield helper
    end

    # Yields an {OpenAIHelper} instance for making OpenAI API calls within a block.
    # Equivalent to {#with_llm} with +provider: :openai+.
    #
    # @param access_token [String, nil] OpenAI API key (defaults to OPENAI_API_KEY env var)
    # @param model [String] the default model for chat requests
    # @param max_completion_tokens [Integer] default maximum tokens in responses
    # @param temperature [Float, nil] default sampling temperature (omitted from
    #   requests when nil)
    # @param base_url [String, nil] OpenAI-compatible API endpoint override
    # @yield [OpenAIHelper] the helper instance for making API calls
    # @return [Object] the block's return value
    # @example Batch processing with pipe
    #   nlp.with_openai(model: "gpt-5-mini") do |ai|
    #     nlp.pipe(texts).map do |doc|
    #       ai.chat(system: "Analyze.", user: doc.linguistic_summary)
    #     end
    #   end
    def with_openai(access_token: nil, model: OpenAIClient::DEFAULT_MODEL,
                    max_completion_tokens: 1000, temperature: nil, base_url: nil)
      helper = OpenAIHelper.new(
        access_token: access_token,
        model: model,
        max_completion_tokens: max_completion_tokens,
        temperature: temperature,
        base_url: base_url
      )
      yield helper
    end

    # Executes a block within spaCy's memory zone for efficient memory management.
    # Requires spaCy >= 3.8.
    # @yield the block to execute within the memory zone
    # @raise [NotImplementedError] if spaCy version does not support memory zones
    def memory_zone(&block)
      major, minor = SpacyVersion.split(".").map(&:to_i)
      unless major > 3 || (major == 3 && minor >= 8)
        raise NotImplementedError, "memory_zone requires spaCy >= 3.8 (current: #{SpacyVersion})"
      end

      PyCall.with(@py_nlp.memory_zone, &block)
    end

    # Methods defined in Python but not wrapped in ruby-spacy can be called by this dynamic method handling mechanism.
    def method_missing(name, *args)
      @py_nlp.send(name, *args)
    end

    def respond_to_missing?(sym, include_private = false)
      Spacy.py_hasattr?(@py_nlp, sym) || super
    end

    def instance_variables_to_inspect
      [:@spacy_nlp_id]
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
      PyCall::List.call(@py_matcher.call(doc.py_doc)).map do |py_match|
        { match_id: py_match[0].to_i, start_index: py_match[1].to_i, end_index: py_match[2].to_i - 1 }
      end
    end
  end

  # See also spaCy Python API document for [`PhraseMatcher`](https://spacy.io/api/phrasematcher).
  # PhraseMatcher is useful for efficiently matching large terminology lists.
  # It's faster than {Matcher} when matching many phrase patterns.
  class PhraseMatcher
    # @return [Object] a Python `PhraseMatcher` instance accessible via `PyCall`
    attr_reader :py_matcher

    # @return [Language] the language model used by this matcher
    attr_reader :nlp

    # Creates a {PhraseMatcher} instance.
    # @param nlp [Language] an instance of {Language} class
    # @param attr [String] the token attribute to match on (default: "ORTH").
    #   Use "LOWER" for case-insensitive matching.
    # @example Case-insensitive matching
    #   matcher = Spacy::PhraseMatcher.new(nlp, attr: "LOWER")
    def initialize(nlp, attr: "ORTH")
      @nlp = nlp
      @py_matcher = PyPhraseMatcher.call(nlp.py_nlp.vocab, attr: attr)
    end

    # Adds phrase patterns to the matcher.
    # @param label [String] a label string given to the patterns
    # @param phrases [Array<String>] an array of phrase strings to match
    # @example Add product names
    #   matcher.add("PRODUCT", ["iPhone", "MacBook Pro", "iPad"])
    def add(label, phrases)
      patterns = phrases.map { |phrase| @nlp.py_nlp.call(phrase) }
      @py_matcher.add(label, patterns)
    end

    # Execute the phrase match and return matching spans.
    # @param doc [Doc] a {Doc} instance to search
    # @return [Array<Span>] an array of {Span} objects with labels
    # @example Find matches
    #   matches = matcher.match(doc)
    #   matches.each { |span| puts "#{span.text} => #{span.label}" }
    def match(doc)
      py_matches = @py_matcher.call(doc.py_doc, as_spans: true)
      PyCall::List.call(py_matches).map { |py_span| Span.new(doc, py_span: py_span) }
    end
  end

  # See also spaCy Python API document for [`Span`](https://spacy.io/api/span).
  class Span
    # @return [Object] a Python `Span` instance accessible via `PyCall`
    attr_reader :py_span

    # @return [Doc] the document to which the span belongs
    attr_reader :doc

    # @return [String] a text string of the span
    attr_reader :text

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
      @py_span = py_span || PySpan.call(@doc.py_doc, start_index, end_index + 1, options)
      @text = @py_span.text
    end

    # Returns an array of tokens contained in the span.
    # @return [Array<Token>]
    def tokens
      PyCall::List.call(@py_span).map { |py_token| Token.new(py_token) }
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
      PyCall::List.call(@py_span.noun_chunks).map do |py_span|
        Span.new(@doc, py_span: py_span)
      end
    end

    # Returns the head token
    # @return [Token]
    def root
      Token.new(@py_span.root)
    end

    # Returns an array of spans that represents sentences.
    # @return [Array<Span>]
    def sents
      PyCall::List.call(@py_span.sents).map do |py_span|
        Span.new(@doc, py_span: py_span)
      end
    end

    # Returns an array of spans that represents named entities.
    # @return [Array<Span>]
    def ents
      PyCall::List.call(@py_span.ents).map do |py_span|
        Span.new(@doc, py_span: py_span)
      end
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
      PyCall::List.call(@py_span.conjuncts).map { |py_conjunct| Token.new(py_conjunct) }
    end

    # Returns tokens that are to the left of the span, whose heads are within the span.
    # @return [Array<Token>] an array of tokens
    def lefts
      PyCall::List.call(@py_span.lefts).map { |py_left| Token.new(py_left) }
    end

    # Returns Tokens that are to the right of the span, whose heads are within the span.
    # @return [Array<Token>] an array of Tokens
    def rights
      PyCall::List.call(@py_span.rights).map { |py_right| Token.new(py_right) }
    end

    # Returns Tokens that are within the span and tokens that descend from them.
    # @return [Array<Token>] an array of tokens
    def subtree
      PyCall::List.call(@py_span.subtree).map { |py_subtree| Token.new(py_subtree) }
    end

    # Returns the label
    # @return [String]
    def label
      @py_span.label_
    end

    # String representation of the span.
    # @return [String]
    def to_s
      @text
    end

    # Methods defined in Python but not wrapped in ruby-spacy can be called by this dynamic method handling mechanism.
    def method_missing(name, *args)
      @py_span.send(name, *args)
    end

    def respond_to_missing?(sym, include_private = false)
      Spacy.py_hasattr?(@py_span, sym) || super
    end

    def instance_variables_to_inspect
      [:@text]
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

    # Returns the character offset of the token within the parent document.
    # @return [Integer]
    def idx
      @py_token.idx
    end

    # Returns the head token
    # @return [Token]
    def head
      Token.new(@py_token.head)
    end

    # Returns the token in question and the tokens that descend from it.
    # @return [Array<Token>] an array of tokens
    def subtree
      PyCall::List.call(@py_token.subtree).map { |descendant| Token.new(descendant) }
    end

    # Returns the token's ancestors.
    # @return [Array<Token>] an array of tokens
    def ancestors
      PyCall::List.call(@py_token.ancestors).map { |ancestor| Token.new(ancestor) }
    end

    # Returns a sequence of the token's immediate syntactic children.
    # @return [Array<Token>] an array of tokens
    def children
      PyCall::List.call(@py_token.children).map { |child| Token.new(child) }
    end

    # The leftward immediate children of the word in the syntactic dependency parse.
    # @return [Array<Token>] an array of tokens
    def lefts
      PyCall::List.call(@py_token.lefts).map { |token| Token.new(token) }
    end

    # The rightward immediate children of the word in the syntactic dependency parse.
    # @return [Array<Token>] an array of tokens
    def rights
      PyCall::List.call(@py_token.rights).map { |token| Token.new(token) }
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

    def respond_to_missing?(sym, include_private = false)
      Spacy.py_hasattr?(@py_token, sym) || super
    end

    def instance_variables_to_inspect
      [:@text]
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

    def respond_to_missing?(sym, include_private = false)
      Spacy.py_hasattr?(@py_lexeme, sym) || super
    end

    def instance_variables_to_inspect
      [:@text]
    end
  end
end

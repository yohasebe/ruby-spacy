# frozen_string_literal: true

module Spacy
  # A helper class for OpenAI API interactions, designed to work with spaCy's
  # linguistic analysis via the block-based {Language#with_llm} /
  # {Language#with_openai} API.
  #
  # With a custom +base_url+, this helper also works with any OpenAI-compatible
  # server such as Ollama, LM Studio, llama.cpp server, or vLLM.
  #
  # @example Basic usage with linguistic_summary
  #   nlp = Spacy::Language.new("en_core_web_sm")
  #   nlp.with_openai(model: "gpt-5-mini") do |ai|
  #     doc = nlp.read("Apple Inc. was founded by Steve Jobs.")
  #     ai.chat(system: "Analyze the linguistic data.", user: doc.linguistic_summary)
  #   end
  #
  # @example Local model via Ollama
  #   nlp.with_llm(provider: :ollama, model: "llama3.2") do |ai|
  #     ai.chat(user: "Say hello.")
  #   end
  class OpenAIHelper
    # @return [String] the default model for chat requests
    attr_reader :model

    # Creates a new OpenAIHelper instance.
    # @param access_token [String, nil] OpenAI API key (defaults to OPENAI_API_KEY env var)
    # @param model [String] the default model for chat requests
    # @param max_completion_tokens [Integer] default maximum tokens in responses
    # @param max_tokens [Integer, nil] alias for max_completion_tokens (takes precedence)
    # @param temperature [Float, nil] default sampling temperature (omitted from
    #   requests when nil; models that reject it are retried without it)
    # @param base_url [String, nil] OpenAI-compatible API endpoint
    #   (e.g., "http://localhost:11434/v1" for Ollama)
    def initialize(access_token: nil, model: OpenAIClient::DEFAULT_MODEL,
                   max_completion_tokens: 1000, max_tokens: nil,
                   temperature: nil, base_url: nil)
      @access_token = access_token || ENV["OPENAI_API_KEY"]
      raise "Error: OPENAI_API_KEY is not set" unless @access_token

      @model = model
      @default_max_completion_tokens = max_tokens || max_completion_tokens
      @default_temperature = temperature
      @client = OpenAIClient.new(access_token: @access_token,
                                 base_url: base_url || OpenAIClient::API_ENDPOINT)
    end

    # Sends a chat completion request.
    #
    # Provides convenient `system:` and `user:` keyword arguments as shortcuts
    # for building simple message arrays. For more complex conversations, pass
    # a full `messages:` array directly.
    #
    # @param system [String, nil] system message content (shortcut)
    # @param user [String, nil] user message content (shortcut)
    # @param messages [Array<Hash>, nil] full message array (overrides system:/user:)
    # @param model [String, nil] model override (defaults to instance model)
    # @param max_completion_tokens [Integer, nil] token limit override
    # @param max_tokens [Integer, nil] alias for max_completion_tokens (takes precedence)
    # @param temperature [Float, nil] temperature override
    # @param response_format [Hash, nil] response format (e.g., { type: "json_object" })
    # @param schema [Hash, nil] JSON Schema for structured outputs; when given,
    #   the model output is constrained to the schema and the parsed Hash is
    #   returned. Objects in the schema must set `additionalProperties: false`
    #   and list all properties in `required`.
    # @param raw [Boolean] if true, returns the full API response Hash instead of text
    # @return [String, Hash, nil] the response text, parsed Hash (if schema:),
    #   full response Hash (if raw:), or nil on error
    def chat(system: nil, user: nil, messages: nil,
             model: nil, max_completion_tokens: nil, max_tokens: nil,
             temperature: nil, response_format: nil, schema: nil, raw: false)
      msgs = messages || build_messages(system: system, user: user)
      raise ArgumentError, "No messages provided. Use system:/user: or messages:" if msgs.empty?

      if schema
        response_format = {
          type: "json_schema",
          json_schema: { name: "response", strict: true, schema: schema }
        }
      end

      response = @client.chat(
        model: model || @model,
        messages: msgs,
        max_completion_tokens: max_tokens || max_completion_tokens || @default_max_completion_tokens,
        temperature: temperature || @default_temperature,
        response_format: response_format
      )

      return response if raw

      choice = response.dig("choices", 0)
      if choice&.dig("finish_reason") == "length"
        warn "Warning: response was truncated (finish_reason: length); consider increasing max_completion_tokens"
      end

      content = choice&.dig("message", "content")
      schema && content ? parse_json_content(content) : content
    rescue OpenAIClient::APIError => e
      warn "Error: OpenAI API call failed - #{e.message}"
      nil
    end

    # Generates text embeddings using the embeddings API.
    #
    # @param text [String] the text to embed
    # @param model [String] the embeddings model
    # @param dimensions [Integer, nil] number of dimensions (nil uses model default)
    # @return [Array<Float>, nil] the embedding vector, or nil on error
    def embeddings(text, model: OpenAIClient::DEFAULT_EMBEDDINGS_MODEL, dimensions: nil)
      response = @client.embeddings(model: model, input: text, dimensions: dimensions)
      response.dig("data", 0, "embedding")
    rescue OpenAIClient::APIError => e
      warn "Error: OpenAI API call failed - #{e.message}"
      nil
    end

    private

    def build_messages(system: nil, user: nil)
      msgs = []
      msgs << { role: "system", content: system } if system
      msgs << { role: "user", content: user } if user
      msgs
    end

    def parse_json_content(text)
      JSON.parse(text)
    rescue JSON::ParserError
      warn "Error: response is not valid JSON (possibly truncated output); returning nil"
      nil
    end
  end
end

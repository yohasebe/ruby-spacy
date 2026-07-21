# frozen_string_literal: true

module Spacy
  # A helper class for Anthropic (Claude) API interactions, designed to work
  # with spaCy's linguistic analysis via the block-based {Language#with_llm} API.
  #
  # Provides the same chat interface as {OpenAIHelper}, so code written against
  # one provider works with the other. Anthropic does not offer an embeddings
  # API; use the :openai or :ollama provider for embeddings.
  #
  # @example Basic usage with linguistic_summary
  #   nlp = Spacy::Language.new("en_core_web_sm")
  #   nlp.with_llm(provider: :anthropic) do |ai|
  #     doc = nlp.read("Apple Inc. was founded by Steve Jobs.")
  #     ai.chat(system: "Analyze the linguistic data.", user: doc.linguistic_summary)
  #   end
  class AnthropicHelper
    # @return [String] the default model for chat requests
    attr_reader :model

    # Creates a new AnthropicHelper instance.
    # @param access_token [String, nil] Anthropic API key (defaults to ANTHROPIC_API_KEY env var)
    # @param model [String] the default model for chat requests
    # @param max_tokens [Integer] default maximum tokens in responses
    # @param temperature [Float, nil] default sampling temperature (omitted from
    #   requests when nil; models that reject it are retried without it)
    # @param base_url [String, nil] API endpoint override
    def initialize(access_token: nil, model: "claude-opus-4-8",
                   max_tokens: 1000, temperature: nil, base_url: nil)
      @access_token = access_token || ENV["ANTHROPIC_API_KEY"]
      raise "Error: ANTHROPIC_API_KEY is not set" unless @access_token

      @model = model
      @default_max_tokens = max_tokens
      @default_temperature = temperature
      @client = AnthropicClient.new(access_token: @access_token,
                                    base_url: base_url || AnthropicClient::API_ENDPOINT)
    end

    # Sends a Messages API request.
    #
    # Provides convenient `system:` and `user:` keyword arguments as shortcuts.
    # For multi-turn conversations, pass a full `messages:` array directly
    # (the system prompt stays a separate `system:` argument — Anthropic takes
    # it as a top-level parameter, not a message role).
    #
    # @param system [String, nil] system prompt
    # @param user [String, nil] user message content (shortcut)
    # @param messages [Array<Hash>, nil] full message array (overrides user:)
    # @param model [String, nil] model override (defaults to instance model)
    # @param max_tokens [Integer, nil] token limit override
    # @param temperature [Float, nil] temperature override
    # @param schema [Hash, nil] JSON Schema for structured outputs; when given,
    #   the model output is constrained to the schema and the parsed Hash is
    #   returned. Objects in the schema must set `additionalProperties: false`.
    # @param raw [Boolean] if true, returns the full API response Hash instead of text
    # @return [String, Hash, nil] the response text, parsed Hash (if schema:),
    #   full response Hash (if raw:), or nil on error or refusal
    def chat(system: nil, user: nil, messages: nil,
             model: nil, max_tokens: nil, temperature: nil,
             schema: nil, raw: false)
      msgs = messages || (user ? [{ role: "user", content: user }] : [])
      raise ArgumentError, "No messages provided. Use user:/messages:" if msgs.empty?

      output_config = schema ? { format: { type: "json_schema", schema: schema } } : nil

      response = @client.messages(
        model: model || @model,
        messages: msgs,
        system: system,
        max_tokens: max_tokens || @default_max_tokens,
        temperature: temperature || @default_temperature,
        output_config: output_config
      )

      return response if raw

      # Safety classifiers can decline a request with HTTP 200 and an empty
      # or partial content array.
      if response["stop_reason"] == "refusal"
        puts "Error: Anthropic API declined the request (stop_reason: refusal)"
        return nil
      end

      text = Array(response["content"])
             .select { |block| block["type"] == "text" }
             .map { |block| block["text"] }
             .join
      schema ? JSON.parse(text) : text
    rescue AnthropicClient::APIError => e
      puts "Error: Anthropic API call failed - #{e.message}"
      nil
    end

    # Anthropic does not provide an embeddings API.
    # @raise [NotImplementedError] always
    def embeddings(*)
      raise NotImplementedError,
            "Anthropic does not provide an embeddings API. " \
            "Use with_llm(provider: :openai) or a local OpenAI-compatible server for embeddings."
    end
  end
end

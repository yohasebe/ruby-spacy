# frozen_string_literal: true

require_relative "llm_client_base"

module Spacy
  # A lightweight OpenAI API client with tools support.
  # This client implements the chat completions and embeddings endpoints
  # without external dependencies.
  #
  # A custom +base_url+ makes it work with any OpenAI-compatible server
  # (Ollama, LM Studio, llama.cpp server, vLLM, OpenRouter, etc.).
  class OpenAIClient < LLMClientBase
    # Default OpenAI API endpoint
    API_ENDPOINT = "https://api.openai.com/v1"
    # Default model for chat requests
    DEFAULT_MODEL = "gpt-5-mini"
    # Default model for embeddings requests
    DEFAULT_EMBEDDINGS_MODEL = "text-embedding-3-small"
    # (see LLMClientBase::APIError)
    APIError = LLMClientBase::APIError

    # @param access_token [String] API key ("ollama" or any placeholder for local servers)
    # @param timeout [Integer] request timeout in seconds
    # @param base_url [String] API endpoint; include the version path
    #   (e.g., "http://localhost:11434/v1" for Ollama)
    def initialize(access_token:, timeout: DEFAULT_TIMEOUT, base_url: API_ENDPOINT)
      super(base_url: base_url, timeout: timeout)
      @access_token = access_token
    end

    # Sends a chat completion request with optional tools support.
    #
    # The +temperature+ parameter is sent only when explicitly given. If the
    # model rejects it (e.g., GPT-5 series and o-series models), the request
    # is retried once without it.
    #
    # @param model [String] The model to use (e.g., "gpt-5-mini")
    # @param messages [Array<Hash>] The conversation messages
    # @param max_completion_tokens [Integer] Maximum tokens in the response
    # @param temperature [Float, nil] Sampling temperature (omitted when nil)
    # @param tools [Array<Hash>, nil] Tool definitions for function calling
    # @param tool_choice [String, Hash, nil] Tool selection strategy
    # @param response_format [Hash, nil] Response format specification (e.g., { type: "json_object" })
    # @return [Hash] The API response
    def chat(model:, messages:, max_completion_tokens: 1000, temperature: nil, tools: nil, tool_choice: nil, response_format: nil)
      body = {
        model: model,
        messages: messages,
        max_completion_tokens: max_completion_tokens
      }
      body[:temperature] = temperature unless temperature.nil?

      if tools && !tools.empty?
        body[:tools] = tools
        body[:tool_choice] = tool_choice || "auto"
      end

      body[:response_format] = response_format if response_format

      post_with_temperature_fallback("/chat/completions", body)
    end

    # Sends an embeddings request.
    #
    # @param model [String] The embeddings model (e.g., "text-embedding-3-small")
    # @param input [String] The text to embed
    # @param dimensions [Integer, nil] The number of dimensions for the output embeddings
    # @return [Hash] The API response
    def embeddings(model:, input:, dimensions: nil)
      body = {
        model: model,
        input: input
      }
      body[:dimensions] = dimensions if dimensions

      post("/embeddings", body)
    end

    private

    def request_headers
      { "Authorization" => "Bearer #{@access_token}" }
    end

    # Models that do not accept the temperature parameter reject it with a 400;
    # retry once without it so callers need no per-model knowledge.
    def post_with_temperature_fallback(path, body)
      post(path, body)
    rescue APIError => e
      raise unless body.key?(:temperature) && e.status_code == 400 && e.message.match?(/temperature/i)

      warn "Warning: model does not support the temperature parameter; retrying without it"
      post(path, body.reject { |key, _| key == :temperature })
    end
  end
end

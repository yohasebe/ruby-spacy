# frozen_string_literal: true

require_relative "llm_client_base"

module Spacy
  # A lightweight Anthropic Messages API client without external dependencies.
  class AnthropicClient < LLMClientBase
    API_ENDPOINT = "https://api.anthropic.com/v1"
    ANTHROPIC_VERSION = "2023-06-01"
    APIError = LLMClientBase::APIError

    # @param access_token [String] Anthropic API key
    # @param timeout [Integer] request timeout in seconds
    # @param base_url [String] API endpoint override
    def initialize(access_token:, timeout: DEFAULT_TIMEOUT, base_url: API_ENDPOINT)
      super(base_url: base_url, timeout: timeout)
      @access_token = access_token
    end

    # Sends a Messages API request.
    #
    # The +temperature+ parameter is sent only when explicitly given. Current
    # Claude models (Opus 4.7+) reject it; the request is then retried once
    # without it.
    #
    # @param model [String] The model to use (e.g., "claude-opus-4-8")
    # @param messages [Array<Hash>] The conversation messages
    # @param system [String, nil] System prompt (top-level parameter)
    # @param max_tokens [Integer] Maximum tokens in the response (required by the API)
    # @param temperature [Float, nil] Sampling temperature (omitted when nil)
    # @param output_config [Hash, nil] Output configuration, e.g.
    #   { format: { type: "json_schema", schema: {...} } } for structured outputs
    # @return [Hash] The API response
    def messages(model:, messages:, system: nil, max_tokens: 1000, temperature: nil, output_config: nil)
      body = {
        model: model,
        max_tokens: max_tokens,
        messages: messages
      }
      body[:system] = system if system
      body[:temperature] = temperature unless temperature.nil?
      body[:output_config] = output_config if output_config

      post("/messages", body)
    rescue APIError => e
      raise unless body.key?(:temperature) && e.status_code == 400 && e.message.match?(/temperature/i)

      warn "Warning: model does not support the temperature parameter; retrying without it"
      post("/messages", body.reject { |key, _| key == :temperature })
    end

    private

    def request_headers
      {
        "x-api-key" => @access_token,
        "anthropic-version" => ANTHROPIC_VERSION
      }
    end
  end
end

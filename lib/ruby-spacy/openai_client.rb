# frozen_string_literal: true

require "net/http"
require "openssl"
require "uri"
require "json"

module Spacy
  # A lightweight OpenAI API client with tools support for GPT-5 series models.
  # This client implements the chat completions and embeddings endpoints
  # without external dependencies.
  class OpenAIClient
    API_ENDPOINT = "https://api.openai.com/v1"
    DEFAULT_TIMEOUT = 120
    MAX_RETRIES = 3
    RETRY_DELAY = 1

    class APIError < StandardError
      attr_reader :status_code, :response_body

      def initialize(message, status_code: nil, response_body: nil)
        @status_code = status_code
        @response_body = response_body
        super(message)
      end
    end

    def initialize(access_token:, timeout: DEFAULT_TIMEOUT)
      @access_token = access_token
      @timeout = timeout
    end

    # Sends a chat completion request with optional tools support.
    # Note: GPT-5 series models do not support the temperature parameter.
    #
    # @param model [String] The model to use (e.g., "gpt-5-mini")
    # @param messages [Array<Hash>] The conversation messages
    # @param max_completion_tokens [Integer] Maximum tokens in the response
    # @param temperature [Float, nil] Sampling temperature (ignored for GPT-5 models)
    # @param tools [Array<Hash>, nil] Tool definitions for function calling
    # @param tool_choice [String, Hash, nil] Tool selection strategy
    # @return [Hash] The API response
    def chat(model:, messages:, max_completion_tokens: 1000, temperature: nil, tools: nil, tool_choice: nil)
      body = {
        model: model,
        messages: messages,
        max_completion_tokens: max_completion_tokens
      }

      # GPT-5 series models do not support temperature parameter
      unless gpt5_model?(model)
        body[:temperature] = temperature || 0.7
      end

      if tools && !tools.empty?
        body[:tools] = tools
        body[:tool_choice] = tool_choice || "auto"
      end

      post("/chat/completions", body)
    end

    # Checks if the model is a GPT-5 series model.
    # GPT-5 models have different parameter requirements (no temperature support).
    def gpt5_model?(model)
      model.to_s.start_with?("gpt-5")
    end

    # Sends an embeddings request.
    #
    # @param model [String] The embeddings model (e.g., "text-embedding-3-small")
    # @param input [String] The text to embed
    # @return [Hash] The API response
    def embeddings(model:, input:)
      body = {
        model: model,
        input: input
      }

      post("/embeddings", body)
    end

    private

    # Creates a certificate store with system CA certificates but without CRL checking.
    # This avoids "unable to get certificate CRL" errors on some systems.
    def default_cert_store
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      store
    end

    def post(path, body)
      uri = URI.parse("#{API_ENDPOINT}#{path}")
      retries = 0

      begin
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.cert_store = default_cert_store
        http.open_timeout = @timeout
        http.read_timeout = @timeout

        request = Net::HTTP::Post.new(uri.path)
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Bearer #{@access_token}"
        request.body = body.to_json

        response = http.request(request)

        handle_response(response)
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        retries += 1
        if retries <= MAX_RETRIES
          sleep RETRY_DELAY
          retry
        end
        raise APIError.new("Request timed out after #{MAX_RETRIES} retries: #{e.message}")
      rescue Errno::ECONNREFUSED, Errno::ECONNRESET, SocketError => e
        retries += 1
        if retries <= MAX_RETRIES
          sleep RETRY_DELAY
          retry
        end
        raise APIError.new("Network error after #{MAX_RETRIES} retries: #{e.message}")
      end
    end

    def handle_response(response)
      body = JSON.parse(response.body)

      case response.code.to_i
      when 200
        body
      when 400..499
        error_message = body.dig("error", "message") || "Client error"
        raise APIError.new(error_message, status_code: response.code.to_i, response_body: body)
      when 500..599
        error_message = body.dig("error", "message") || "Server error"
        raise APIError.new(error_message, status_code: response.code.to_i, response_body: body)
      else
        raise APIError.new("Unexpected response: #{response.code}", status_code: response.code.to_i, response_body: body)
      end
    rescue JSON::ParserError
      raise APIError.new("Invalid JSON response", status_code: response.code.to_i, response_body: response.body)
    end
  end
end

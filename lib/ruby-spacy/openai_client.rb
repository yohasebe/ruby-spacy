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
    BASE_RETRY_DELAY = 1

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
    # Note: GPT-5 series and o-series models do not support the temperature parameter.
    #
    # @param model [String] The model to use (e.g., "gpt-5-mini")
    # @param messages [Array<Hash>] The conversation messages
    # @param max_completion_tokens [Integer] Maximum tokens in the response
    # @param temperature [Float, nil] Sampling temperature (ignored for models that don't support it)
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

      # GPT-5 series and o-series models do not support temperature parameter
      unless temperature_unsupported?(model)
        body[:temperature] = temperature || 0.7
      end

      if tools && !tools.empty?
        body[:tools] = tools
        body[:tool_choice] = tool_choice || "auto"
      end

      body[:response_format] = response_format if response_format

      post("/chat/completions", body)
    end

    # Checks if the model does not support the temperature parameter.
    # This includes GPT-5 series and o-series (o1, o3, o4-mini, etc.) models.
    # @param model [String] The model name
    # @return [Boolean]
    def temperature_unsupported?(model)
      name = model.to_s
      name.start_with?("gpt-5") || name.match?(/\Ao\d/)
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

      loop do
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

          # Handle 429 rate limiting before general response handling
          if response.code.to_i == 429
            retries += 1
            if retries <= MAX_RETRIES
              retry_after = response["Retry-After"]&.to_f
              delay = retry_after || (BASE_RETRY_DELAY * (2**(retries - 1)) + rand * 0.5)
              sleep delay
              next
            end
            raise APIError.new("Rate limited after #{MAX_RETRIES} retries",
                               status_code: 429, response_body: response.body)
          end

          return handle_response(response)
        rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, Errno::ECONNRESET, SocketError => e
          retries += 1
          if retries <= MAX_RETRIES
            delay = BASE_RETRY_DELAY * (2**(retries - 1)) + rand * 0.5
            sleep delay
            next
          end
          raise APIError.new("Network error after #{MAX_RETRIES} retries: #{e.message}")
        end
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

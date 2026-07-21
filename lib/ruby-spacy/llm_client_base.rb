# frozen_string_literal: true

require "net/http"
require "openssl"
require "uri"
require "json"

module Spacy
  # Shared HTTP layer for LLM API clients ({OpenAIClient}, {AnthropicClient}).
  # Implements JSON POST requests with retry on rate limits (429/529) and
  # transient network errors, using only net/http (no external dependencies).
  class LLMClientBase
    # Default request timeout in seconds
    DEFAULT_TIMEOUT = 120
    # Maximum number of retries for rate-limited requests and network errors
    MAX_RETRIES = 3
    # Base delay in seconds for exponential backoff between retries
    BASE_RETRY_DELAY = 1

    # Raised when an LLM API request fails after retries; carries the HTTP
    # status code and the parsed response body when available.
    class APIError < StandardError
      attr_reader :status_code, :response_body

      def initialize(message, status_code: nil, response_body: nil)
        @status_code = status_code
        @response_body = response_body
        super(message)
      end
    end

    def initialize(base_url:, timeout: DEFAULT_TIMEOUT)
      @base_url = base_url.sub(%r{/\z}, "")
      @timeout = timeout
    end

    private

    # Subclasses provide authentication and API-specific headers.
    # @return [Hash{String => String}]
    def request_headers
      {}
    end

    # Creates a certificate store with system CA certificates but without CRL checking.
    # This avoids "unable to get certificate CRL" errors on some systems.
    def default_cert_store
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      store
    end

    def post(path, body)
      uri = URI.parse("#{@base_url}#{path}")
      retries = 0

      loop do
        begin
          http = Net::HTTP.new(uri.host, uri.port)
          if uri.scheme == "https"
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            http.cert_store = default_cert_store
          end
          http.open_timeout = @timeout
          http.read_timeout = @timeout

          request = Net::HTTP::Post.new(uri.request_uri)
          request["Content-Type"] = "application/json"
          request_headers.each { |key, value| request[key] = value }
          request.body = body.to_json

          response = http.request(request)

          # Handle rate limiting (429) and overload (529) before general response handling
          if [429, 529].include?(response.code.to_i)
            retries += 1
            if retries <= MAX_RETRIES
              retry_after = response["Retry-After"]&.to_f
              delay = retry_after || (BASE_RETRY_DELAY * (2**(retries - 1)) + rand * 0.5)
              sleep delay
              next
            end
            raise APIError.new("Rate limited after #{MAX_RETRIES} retries",
                               status_code: response.code.to_i, response_body: response.body)
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

require_relative '../faraday_connector'

module Replicate
  module ApiConnector
    include FaradayConnector

    def url
      'https://api.replicate.com'
    end

    def auth
      "Bearer #{ENV['REPLICATE_API_KEY']}"
    end

    def content_type
      'application/json'
    end
  end
end

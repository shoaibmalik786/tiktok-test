require_relative '../faraday_connector'

module Imagineapi
  module ApiConnector
    include FaradayConnector

    def url
      'https://cl.imagineapi.dev'
    end

    def auth
      "Bearer #{ENV['IMAGINEAPI_API_KEY']}"
    end

    def content_type
      'application/json'
    end
  end
end

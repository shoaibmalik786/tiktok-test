require_relative '../faraday_connector'

module Openai
  module ApiConnector
    include FaradayConnector
  
    def url
      'https://api.openai.com'
    end
  
    def auth
      "Bearer #{ENV['OPENAI_API_KEY']}"
    end
  end
end

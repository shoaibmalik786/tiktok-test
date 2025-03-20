module Imagineapi
  class ImageGenerations
    include ApiConnector

    attr_reader :body

    def initialize(prompt:)
      @body = { prompt: prompt }
    end

    def do_request
      post('/items/images', body)
    end

    def do_process
      response = request.value!
    end
  end
end

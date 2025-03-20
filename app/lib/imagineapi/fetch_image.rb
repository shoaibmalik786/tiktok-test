module Imagineapi
  class FetchImage
    include ApiConnector

    attr_reader :image_id

    def initialize(image_id:)
      @image_id = image_id
    end

    def do_request
      get("/items/images/#{image_id}")
    end

    def do_process
      response = request.value!
    end
  end
end

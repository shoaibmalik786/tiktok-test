module Openai
  class ImageGenerations
    include ApiConnector

    attr_reader :body

    def initialize(prompt:, model:, n:, quality: 'hd', response_format: 'url', size: '1024x1792', style: 'vivid', user: nil)
      @body = {}
      @body.merge!(prompt: prompt) if prompt.present?
      @body.merge!(model: model) if model.present?
      @body.merge!(n: n) if n.present?
      @body.merge!(quality: quality) if quality.present?
      @body.merge!(response_format: response_format) if response_format.present?
      @body.merge!(size: size) if size.present?
      @body.merge!(style: style) if style.present?
      @body.merge!(user: user) if user.present?
    end

    def do_request
      post('v1/images/generations', body)
    end

    def do_process
      response = request.value!
    end
  end
end

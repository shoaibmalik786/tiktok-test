module Replicate
  class ImageGenerations
    include ApiConnector

    attr_reader :model, :body

    def initialize(model:, prompt:, prompt_upsampling: nil, aspect_ratio: nil)
      @model = model
      @body = {
        input: {
          prompt: prompt
        }
      }

      @body[:input].merge!(prompt_upsampling: prompt_upsampling) if prompt_upsampling.present?
      @body[:input].merge!(aspect_ratio: aspect_ratio) if aspect_ratio.present?
    end

    def do_request
      post(endpoint, body)
    end

    def do_process
      response = request.value!
    end

    private

    def endpoint
      case model.to_sym
      when :ideogram
        '/v1/models/ideogram-ai/ideogram-v2/predictions'
      when :flux_pro
        '/v1/models/black-forest-labs/flux-1.1-pro/predictions'
      when :imagen_3
        '/v1/models/google/imagen-3/predictions'
      else
        raise "Unknown model: #{model}"
      end
    end
  end
end

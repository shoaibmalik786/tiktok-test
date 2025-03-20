module Openai
  class ChatCompletions
    include ApiConnector

    attr_reader :body

    def initialize(
      messages:, model:, frequency_penalty: nil, logit_bias: nil, logprobs: nil, top_logprobs: nil, max_tokens: nil,
      n: nil, presence_penalty: nil, response_format: nil, seed: nil, stop: nil, stream: nil, stream_options: nil,
      temperature: nil, top_p: nil, tools: nil, tool_choice: nil, user: nil
    )
      @body = {}
      @body.merge!(messages: messages) if messages.present?
      @body.merge!(model: model) if model.present?
      @body.merge!(frequency_penalty: frequency_penalty) if frequency_penalty.present?
      @body.merge!(logit_bias: logit_bias) if logit_bias.present?
      @body.merge!(logprobs: logprobs) if logprobs.present?
      @body.merge!(top_logprobs: top_logprobs) if top_logprobs.present?
      @body.merge!(max_tokens: max_tokens) if max_tokens.present?
      @body.merge!(n: n) if n.present?
      @body.merge!(presence_penalty: presence_penalty) if presence_penalty.present?
      @body.merge!(response_format: response_format) if response_format.present?
      @body.merge!(seed: seed) if seed.present?
      @body.merge!(stop: stop) if stop.present?
      @body.merge!(stream: stream) if stream.present?
      @body.merge!(stream_options: stream_options) if stream_options.present?
      @body.merge!(temperature: temperature) if temperature.present?
      @body.merge!(top_p: top_p) if top_p.present?
      @body.merge!(tools: tools) if tools.present?
      @body.merge!(tool_choice: tool_choice) if tool_choice.present?
      @body.merge!(user: user) if user.present?
    end

    def do_request
      post('v1/chat/completions', body)
    end

    def do_process
      request.value!
      # additional data manipulations goes here
    end
  end
end

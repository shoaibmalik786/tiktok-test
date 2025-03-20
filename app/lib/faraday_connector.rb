require 'faraday'
require 'faraday_curl'
require 'concurrent'

module FaradayConnector
  class ServerError < RuntimeError
    attr_reader :response

    def initialize(response)
      @response = response
      super
    end
  end

  class TimeoutError < RuntimeError; end
  class ClientError < RuntimeError; end

  def request
    return @_request if defined?(@_request)

    # creating a Promise for async approach
    @_request = Concurrent::Promises.future { do_request }
  end

  def process
    return @_process if defined?(@_process)

    request
    @_process = do_process
  end

  def as_json(_options = {})
    process
  end

  protected

  def do_request
    # implement the real request in Child
  end

  def do_process
    # implement additional response decorations in Child
    request.value!
  end

  def url
    # must be added in Child
    raise 'Undefined url'
  end

  def auth
    # must be added in Child or use nil, if API has no Authorization
    raise 'Undefined auth'
  end

  def additional_headers
    {}
  end

  def content_type
    'application/json'
  end

  def request_type
    :url_encoded
  end

  def get(path, params = {})
    handle_request { connection.get(path, params) }
  end

  def post(path, body = {})
    formatted_body = json_content? ? body.to_json : body
    handle_request { connection.post(path, formatted_body) }
  end

  def delete(path, params = {})
    handle_request { connection.delete(path, params) }
  end

  def put(path, body = {})
    formatted_body = json_content? ? body.to_json : body
    handle_request { connection.put(path, formatted_body) }
  end

  def timeout
    45
  end

  def connection
    @connection ||= Faraday.new(url: url) do |faraday|
      faraday.request request_type
      faraday.headers['Authorization'] = auth if auth
      faraday.headers['Content-Type'] = content_type
      faraday.headers = faraday.headers.merge(additional_headers) if additional_headers
      faraday.options.timeout = timeout
      faraday.response(:logger)
      faraday.request :curl, Logger.new($stdout), :info
      faraday.adapter Faraday.default_adapter
    end
  end

  def handle_request
    response = handle_errors { yield }
    parse_response(response)
  end

  # just an easier way to handle HTTP errors
  def handle_errors
    response = yield
    e = if [502, 504].include?(response.status)
          TimeoutError.new(response)
        elsif [500, 503].include?(response.status)
          ServerError.new(response)
        elsif [400, 401, 404, 422].include?(response.status)
          ClientError.new(response)
        end
    return response unless e

    raise e
  end

  def parse_response(response)
    return {} unless response.body

    json_content? ? JSON.parse(response.body) : response
  rescue JSON::ParserError
    {}
  end

  def json_content?
    content_type == 'application/json'
  end
end

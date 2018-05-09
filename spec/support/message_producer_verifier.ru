# TODO provider states

require 'json'

class Provider
  def a_test_message
    {
      text: "Hello world!!"
    }
  end
end

class MessageCreator
  def initialize provider
    @provider = provider
  end

  def create message_descriptor
    message_creation_method = message_descriptor.description.downcase.gsub(' ', '_').to_sym
    message_content = @provider.send(message_creation_method)
    { contents: message_content }
  end
end

class HttpRequestHandler
  def initialize message_creator
    @message_creator = message_creator
  end

  def call env
    request_body = JSON.parse(env['rack.input'].read)
    message_descriptor = OpenStruct.new(request_body)
    response_body = @message_creator.create(message_descriptor)
    [200, {'Content-Type' => 'application/json'}, [response_body.to_json]]
  end

end

run HttpRequestHandler.new(MessageCreator.new(Provider.new))

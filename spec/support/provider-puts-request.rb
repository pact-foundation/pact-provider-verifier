require 'socket'
require 'stringio'
require 'delegate'

class Putser < SimpleDelegator
  def gets *args
    __getobj__().gets(*args).tap { |it| $stdout.puts it }
  end

  def read *args
    __getobj__().read(*args).tap { |it| $stdout.puts it }
  end
end

server = TCPServer.new 2000 # Server bind to port 2000
loop do
  client = Putser.new(server.accept)       # Wait for a client to connect

  method, path = client.gets.split
  headers = {}
  while line = client.gets.split(' ', 2)
    break if line[0] == ""
    headers[line[0].chop] = line[1].strip
  end
  data = client.read(headers["Content-Length"].to_i)

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Length: 0"
  client.puts ""
  client.close
end

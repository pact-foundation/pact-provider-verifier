require 'socket'

server = TCPServer.new 2000 # Server bind to port 2000
loop do
  client = server.accept    # Wait for a client to connect
  puts "ACCEPTED connection"
  client.puts "HTTP/1.1 200 OK"
  client.close
end

require 'socket'

port = ARGV[0] ? ARGV[0].to_i : 9292

puts "Starting TCP server on port #{port}"

server = TCPServer.new(port)
puts "Listening"

while session = server.accept
  request_lines = []
  while line = session.gets
    request_lines << line
    puts "DEBUG: #{line}"
    break if request_lines[-1] == "\r\n" && request_lines[-2].end_with?("\r\n")
  end
  request = request_lines.join

  if request.include?("Access_token: 123")
    session.print "HTTP/1.1 200\r\n" # 1
    session.print "Content-Type: text/plain\r\n" # 2
    session.print "\r\n" # 3
    session.print "Hello world" #4
  else
    session.print "HTTP/1.1 401\r\n" # 1
  end
  session.close
end

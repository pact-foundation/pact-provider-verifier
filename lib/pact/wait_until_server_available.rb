require 'socket'
require 'time'

module Pact
  module WaitUntilServerAvailable
    def self.call(host, port, wait_time = 15)
      end_time = Time.now + wait_time
      tries = 0
      begin
        sleep 2 if tries != 0
        Socket.tcp(host, port, connect_timeout: 3) {}
        true
      rescue => e
        tries += 1
        retry if Time.now < end_time
        return false
      end
    end

    def wait_until_server_available *args
      WaitUntilServerAvailable.call(*args)
    end
  end
end

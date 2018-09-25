#! /usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '/lib'))

require 'simple-rpc'

class Client

  def initialize
    @rpc = SimpleRPC::RPC.new(self)
    @rpc.add_listener(SimpleRPC::Events::CONNECTION_CHANGED, method(:connection_changed))
    @rpc.connect
  end

  def connection_changed(status)
    puts "status = #{status}"
    if status == SimpleRPC::Status::CONNECTED
      test_all
    end
  end

  def test_all
    @rpc.send_msg("say_hello", "awesome", "dude")
    @rpc.send_msg("test_hash", {test:"asdf"})
    @rpc.send_msg("test_callback", {test:"asdf"}, "some_method")
  end

  def some_method(data)
    puts "some_method called with #{data}"
  end

end

client = Client.new
puts "Press enter to send again:"
while true
  gets.chomp
  client.test_all
  sleep 1
end

#! /usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '/lib'))

require 'simple-rpc'

class Client

  def initialize
    @rpc = SimpleRPC::RPC.new(self)
    @rpc.connect
  end

  def say_hello(adjective, sender)
    puts "hello #{adjective} #{sender}"
  end

  def test_hash(data)
    puts "hash = #{data}"
  end

  def test_callback(data, callback)
    puts "calling #{callback} with #{data}"
    @rpc.send_msg callback, data
  end

end

Client.new
while true
  sleep 1
end

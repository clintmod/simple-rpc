#! /usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '/lib'))

require 'simple-rpc'

class Client

  def initialize
    @rpc = SimpleRPC.new(self)
    @rpc.add_listener(LocalSocketEvents::CONNECTION_CHANGED, method(:connection_changed))
    @rpc.connect
  end

  def connection_changed(status)
    puts "status = #{status}"
    if status == LocalSocketStatus::CONNECTED
      test_all
    end
  end

  def test_all
    @rpc.send_msg("say_hello", "awesome", "dude")
    @rpc.send_msg("test_hash", {test:"asdf"})
    @rpc.send_msg("test_class", TestClass.new('asdf1', 'asdf2'))
  end

  def say_hello(adjective, sender)
    puts "hello #{adjective} #{sender}"
  end

  def test_hash(some_hash)
    puts "hash = #{some_hash}"
  end

  def test_class(test_class)
    puts "test_class = #{test_class}"
  end

end

class TestClass
  def initialize(a, b)
    @a = a
    @b = b
  end

  def to_json(options = {})
    {'a' => @a, 'b' => @b}.to_json
  end

  def self.from_json string
    data = JSON.load string
    self.new data['a'], data['b']
  end
end

Client.new
while true
  sleep 1
end

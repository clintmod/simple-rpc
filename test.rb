#! /usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '/lib'))

require 'simple-rpc'

class Client

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

client = Client.new
@rpc = SimpleRPC.new(client)

loop do
  puts "Press enter to test strings"
  $stdin.gets.chomp
  @rpc.send_msg("say_hello", "awesome", "dude")

  puts "Press enter to test hashes"
  $stdin.gets.chomp
  @rpc.send_msg("test_hash", {test:"asdf"})

  puts "Press enter to test class instance"
  $stdin.gets.chomp
  @rpc.send_msg("test_class", TestClass.new('asdf1', 'asdf2'))
end

#! /usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '/lib'))

require 'simple-rpc'

class Client

  def initialize
    @rpc = SimpleRPC.new(self)
  end

  def say_hello(adjective, sender)
    puts "hello #{adjective} #{sender}"
  end

  def test
    @rpc.send_msg("say_hello", "awesome", "dude")
  end

end

client = Client.new

puts "Press enter to test"
loop do
  $stdin.gets.chomp
  client.test
end

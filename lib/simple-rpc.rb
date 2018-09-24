require 'json'
require 'local_socket'

class SimpleRPC

  def initialize(client)
    @client = client
    is_child = ENV['CHILD'] ? true : false
    parent_channel = ENV['CHANNEL'] + '_parent'
    child_channel = ENV['CHANNEL'] + '_child'
    receive_channel = is_child ? parent_channel : child_channel
    send_channel = is_child ? child_channel : parent_channel
    @socket = LocalSocket.new(receive_channel, send_channel)

    @socket.message_received do | json_array_string |
      array = JSON.parse(json_array_string)
      @client.send(*array)
    end
    @socket.connection_changed do |connected|
      puts "Connection changed: connected = #{connected}"
    end
  end

  def send_msg(*args)
    msg = JSON.generate(args)
    @socket.send_msg msg
  end

end

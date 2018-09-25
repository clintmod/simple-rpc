require 'json'
require 'local_socket'
require 'local_socket_events'

class SimpleRPC

  def initialize(client)
    @client = client
    is_child = ENV['CHILD'] ? true : false
    parent_channel = ENV['CHANNEL'] + '_parent'
    child_channel = ENV['CHANNEL'] + '_child'
    receive_channel = is_child ? parent_channel : child_channel
    send_channel = is_child ? child_channel : parent_channel
    @socket = LocalSocket.new(receive_channel, send_channel)
    @socket.add_listener(LocalSocketEvents::MESSAGE_RECEIVED, method(:message_received))
  end

  def message_received json_array_string
    array = JSON.parse(json_array_string)
    @client.send(*array)
  end

  def connect
    @socket.connect
  end

  def send_msg(*args)
    msg = JSON.generate(args)
    @socket.send_msg msg
  end

  def status_changed
    @socket.status_changed
  end

  def add_listener(event, listener)
    @socket.add_listener event, listener
  end

end

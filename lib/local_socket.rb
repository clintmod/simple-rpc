require 'set'
require 'socket'
require 'local_socket_events'
require 'local_socket_status'

class LocalSocket
  attr_reader :status
  
  CONNECTION_TEST = "connection_test"

  def initialize(receive_channel, send_channel, max_message_size=5000, thread_sleep=0.1)
    @receive_channel = receive_channel
    @send_channel = send_channel
    @max_message_size = max_message_size
    @thread_sleep = thread_sleep
    @last_status = nil
    @status = false
    @receiver_thread = nil
    @_thread = nil
    @listeners = {}
  end

  def send_msg(msg)
    flag = false
    begin
      @socket.sendmsg_nonblock(msg, 0, @snd_addrInfo)
      flag = true
    rescue => e
      puts "Error: #{e}" unless "#{e}".include? "Connection refused" or "#{e}".include? "No such file"
      flag = false
    end
    return flag
  end

  def connect
    puts "calling connect"
    bind
    setup_receiver_thread
    setup_status_thread
    puts "finished calling connect"
  end

  def bind
    begin
      File.unlink @receive_channel
    rescue => e
      puts "#{e}" unless "#{e}".include? "No such file"
    end
    @socket = Socket.new(:UNIX, :DGRAM, 0)
    @snd_addrInfo = Addrinfo.unix(@send_channel)
    @rcv_addrInfo = Addrinfo.unix(@receive_channel)
    @socket.bind(@rcv_addrInfo)
  end

  def setup_receiver_thread
    @receiver_thread = Thread.new do
      loop do
        begin
          result = @socket.recv_nonblock(@max_message_size)
          if result != CONNECTION_TEST
            notify(LocalSocketEvents::MESSAGE_RECEIVED, result)
          end
        rescue => e
          puts "#{e}" unless "#{e}".include? "would block"
        end
        sleep @thread_sleep
      end
    end
  end

  def setup_status_thread
    @status_thread = Thread.new do
      # todo:clintmod implement timeout
      loop do
        if send_msg(CONNECTION_TEST) 
          @status = LocalSocketStatus::CONNECTED
        else
          @status = LocalSocketStatus::DISCONNECTED
        end
        if @last_status != @status
          notify(LocalSocketEvents::CONNECTION_CHANGED, @status)
        end
        @last_status = @status
        sleep @thread_sleep
      end
    end
  end

  def add_listener(event, listener)
    @listeners[event] ||= Set.new
    @listeners[event] << listener
  end

  def notify(event, data)
    puts "notify with event: #{event}, data: #{data}"
    @listeners[event] && @listeners[event].each do |listener|
      listener.call data
    end
  end

end

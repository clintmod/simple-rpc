require 'socket'

class LocalSocket
  attr_reader :connected
  CONNECTION_TEST = "connection_test"

  def initialize(receive_channel, send_channel, max_message_size=5000, thread_sleep=0.1, socket_timeout=60)
    @receive_channel = receive_channel
    @send_channel = send_channel
    @max_message_size = max_message_size
    @thread_sleep = thread_sleep
    @last_connected_status = nil
    @connected = false
    @receiver_thread = nil
    @connection_thread = nil
    bind
  end

  def send_msg(msg)
    flag = false
    begin
      @socket.sendmsg_nonblock(msg, 0, @snd_addrInfo)
      flag = true
    rescue => e
      puts "Error: #{e}" unless "#{e}".include? "Connection refused"
      flag = false
    end
    return flag
  end

  def bind
    begin
      File.unlink @receive_channel
    rescue => e
      puts "#{e}"
    end
    @socket = Socket.new(:UNIX, :DGRAM, 0)
    @snd_addrInfo = Addrinfo.unix(@send_channel)
    @rcv_addrInfo = Addrinfo.unix(@receive_channel)
    @socket.bind(@rcv_addrInfo)
  end

  def join
    @receiver_thread.join
  end


  def message_received
    @receiver_thread = Thread.new do
      loop do
        begin
          result = @socket.recv_nonblock(@max_message_size)
          if result != CONNECTION_TEST
            yield result
          end
        rescue => e
          puts "#{e}" unless "#{e}".include? "would block"
        end
        sleep @thread_sleep
      end
    end
  end

  def connection_changed
    @connection_thread = Thread.new do
      loop do
        if send_msg(CONNECTION_TEST) 
          @connected = true
        else
          @connected = false
        end
        if @last_connected_status != @connected
          yield @connected
        end
        @last_connected_status = @connected
        sleep @thread_sleep
      end
    end
  end

end

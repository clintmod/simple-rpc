# SimpleRPC

A simple ruby library for doing machine local interprocess communication using unix sockets.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple-rpc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple-rpc

## Usage

You can clone this repository and open two different console windows and run:

Console 1

`CHANNEL=/tmp/asdf ./client1.rb `

Console 2

`CHANNEL=/tmp/asdf CHILD=1 ./client2.rb`


The `CHILD=1` env var flips the channels in the second process so that they the two processes can send and receive on two local unix sockets as defined by the `CHANNEL` env var.


Here's the contents of ./client1.rb

```

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
  end

end

Client.new
while true
  sleep 1
end

```

and here are the contents of ./client2.rb

```

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

end

Client.new
while true
  sleep 1
end


```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/clintmod/simple-rpc.

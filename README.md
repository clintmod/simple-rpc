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

`CHANNEL=/tmp/asdf ./test.rb `

Console 2

`CHANNEL=/tmp/asdf CHILD=1 ./test.rb`


The `CHILD=1` env var flips the channels in the second process so that they the two processes can send and receive on two local unix sockets as defined by the `CHANNEL` env var.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/clintmod/simple-rpc.

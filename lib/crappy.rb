require 'crappy/conf'
require 'crappy/irc'
require 'eventmachine'

module Crappy
  class Bot
    def initialize
      begin
        @config = Conf::parse()
      rescue Exception => e
        abort("Error reading configuration: #{e.message}")
      end
    end

    def run
      EventMachine.run do
        @config.servers.each do |server_name, server_options|
          IRC::connect(server_name, server_options)
        end

        Signal.trap('SIGINT') do
          EventMachine.next_tick do
            puts "Received SIGINT"
            EventMachine.stop_event_loop()
          end
        end
      end
    end
  end
end

module Crappy
  module IRC
    module ExtensionManager
      @@events = Hash.new()
      def self.extend(event, block)
        if @@events.has_key?(event)
          @@events[event] << block
        else
          @@events[event] = [block]
        end
      end
      def self.emit(connection, event, source, params )
        if @@events.has_key?(event)
          @@events[event].each do |block|
            block.call(connection, source, params)
          end
        end
      end

    end
    def IRC.extension(event, &block)
      ExtensionManager.extend(event.upcase(), block)
    end
  end
end

Crappy::IRC::extension "PING" do |connection, source, params|
  puts "PONG :#{params[0]}"
  connection.send_line("PONG :#{params[0]}")
end

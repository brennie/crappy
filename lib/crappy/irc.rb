require 'uri'
require 'eventmachine'
require 'crappy/irc/parser'
require 'crappy/irc/message'
require 'crappy/irc/extension'

module URI
  class IRC < Generic
    DEFAULT_PORT = 6667
    COMPONENT = [:scheme, :host, :port]
  end
  class IRCS < IRC
    DEFAULT_PORT = 6697
  end
  
  @@schemes['IRC'] = IRC
  @@schemes['IRCS'] = IRCS
end

module Crappy

  module IRC

    def IRC.connect(name, options)
      if options.ssl?
        connectionType = SecureConnection
      else
        connectionType = Connection
      end
      
      EventMachine::connect(options.host, options.port, connectionType, name, options)
    end

    class Buffer
      def initialize
        @data = String.new()
        @lines = Array.new()
      end

      def <<(data)
        @data << data
        while @data != nil && @data.include?("\r\n")
          line, @data = @data.split("\r\n", 2)
          @lines << line
        end
        if @data == nil
          @data = String.new()
        end
      end

      def has_line?
        @lines.length() > 0
      end

      def get_line
        @lines.pop()
      end
    end

    class Connection < EventMachine::Connection
      attr_reader :name
      def initialize(name, options)
        @name = name
        @host = options.host
        @port = options.port
        @ssl = options.ssl?
        @nickname = options.nickname
        @username = options.username 
        @realname = options.realname
        @to_join = options.channels
        @buffer = Buffer.new()
      end

      def ready
        send_line("NICK #{@nickname}")
        send_line("USER #{@username} * 0 :#{@realname}")

        @to_join.each do |channel|
          send_line("JOIN #{channel.name} #{channel.key}")
        end
        
      end

      def send_line(line)
        send_data(line)
        send_data("\r\n")
      end

      def receive_data(data)
        @buffer << data
        while @buffer.has_line?
          line = @buffer.get_line()
          message = Parser::parse(line)
          ExtensionManager::emit(self, message.command, message.source, message.params)
        end
      end
      
      def connection_completed
        ready()
      end
    end

    class SecureConnection < Connection
      def connection_completed
        start_tls()
      end

      def ssl_handshake_completed
        ready()
      end
    end

  end # module IRC

end #module Crappy

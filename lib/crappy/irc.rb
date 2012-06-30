require 'uri'
require 'eventmachine'
require 'pp'
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
      
      EventMachine::connect(options.host, options.port, connectionType, options)
    end

    class Connection < EventMachine::Connection

      def initialize(options)
        @host = options.host
        @port = options.port
        @ssl = options.ssl?
        @nickname = options.nickname
        @username = options.username 
        @realname = options.realname
        @to_join = options.channels
      end

      def ready
        send_data("NICK #{@nickname}\r\n")
        send_data("USER #{@username} * 0 :#{@realname}\r\n")

        @to_join.each do |channel|
          send_data("JOIN #{channel.name} #{channel.key}\r\n")
        end
        
      end

      def receive_data(data)
        pp data
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
  end
end

require 'crappy/conf'

module Crappy
  class Bot
    def initialize
      begin
        @config = Conf::parse()
      rescue Exception => e
        abort("Error reading configuration: #{e.message}")
      end
    end
  end
end

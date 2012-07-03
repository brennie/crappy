module Crappy
  module IRC
    Source = Struct.new(:nickname, :username, :hostname)

    Message = Struct.new(:source, :command, :params)
  end
end

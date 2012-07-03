require 'yaml'
require 'ostruct'
require 'crappy/irc'

module Crappy

  module Conf
    class Exception < Exception
    end
    
    def Conf.parse
      yaml = YAML::load(File.open('config.yaml'))

      config = OpenStruct.new()

      # The global 'nickname', 'username', and 'realname' definitions are
      # included into individual server configurations if they are absent.
      # Otherwise they are not included.
      
      global_opts = Hash.new()
      names = ['nickname', 'username', 'realname']

      names.each do |name|
        if yaml.has_key?(name)
          global_opts[name] = yaml[name]
        end
      end
      
      if !yaml.has_key?('servers') || yaml['servers'].length() == 0
        raise Exception.new('No servers specified.')
      end

      config.servers = Hash.new()
      yaml['servers'].each do |server_name, server_opts|
        server = OpenStruct.new()
        
        if !server_opts.has_key?('uri')
          raise Exception.new("Server '#{server_name}' has no URI")
        end
        

        uri = URI.parse(server_opts['uri'])

        if !['irc', 'ircs'].include?(uri.scheme)
          raise Exception.new("Server '#{server_name}' does not have an irc:// or ircs:// URI")
        end

        if !['', '/'].include?(uri.path)
          raise Exception.new("IRC URI paths not supported")
        end

        server.port = uri.port
        server.host = uri.host
        server.send('ssl?=', uri.scheme == 'ircs')


        names.each do |name|
          if server_opts.has_key?(name)
            server.send("#{name}=", server_opts[name])
          elsif global_opts.has_key?(name)
            server.send("#{name}=", global_opts[name])
          else
            raise Exception.new("Server '#{server_name}' has no '#{name}' and no global '#{name}' is set")
          end
        end

        if server_opts.has_key?('channels')
          server.channels = Array.new()

          server_opts['channels'].each do |channel|
            if !channel.has_key?('name')
              raise Exception.new('All channels must have a name')
            end
            
            server.channels << OpenStruct.new(:name => channel['name'], :key => channel['key'])
          end
        else
          server.channels = nil
        end

        config.servers[server_name] = server
      end

      if !yaml.has_key?('plugins') || yaml['plugins'].length() == 0
        config.plugins = nil
      else
        config.plugins = Array.new()

        yaml['plugins'].each do |plugin, options|
          config.plugins << OpenStruct.new(:name => plugin, :options => options.length() > 0 ? options : nil)
        end
      end

      config

    end
  end

end

require 'ostruct'
require 'crappy/irc/message'

%%{
  machine irc_parser;

  action mark { mark = p }
  action set_nickname { source.nickname = data[mark .. p - 1] }
  action set_username { source.username = data[mark .. p - 1] }
  action set_hostname { source.hostname = data[mark .. p - 1] }
  action set_command  { command = data[mark .. p - 1] }
  action add_param    { params << data[mark .. p - 1] }

  valid = extend -- ('\r' | '\n' | 0);
  nospace = extend -- ('\r' | '\n' | 0 | ' ');
  special = '[' | ']' | '{' | '}' | '^' | '`' | '\\' | '-';

  nickname = (alpha (alpha | digit | special)*) >mark %set_nickname;
  username = (valid -- '@')+ >mark %set_username;

  # We allow basically anything in the host. RFC 2812 specifies that it should
  # be a valid domain, but that will break on servers that use custom hosts
  # (e.g. Freenode)
  hostname = nospace+ >mark %set_hostname;

  prefix = ':' (nickname ('!' username)? '@')? hostname ' ';

  command = ([0-9]{3}|alpha+) >mark %set_command;

  middle = ' ' ((nospace -- ':') nospace*) >mark %add_param;
  trailing = ' :' (valid+) >mark %add_param;

  main := prefix? command middle* trailing?;
}%%

module Crappy
  module IRC
    module Parser
    %%write data;

      def Parser.parse(data)
        p = 0
        eof = pe = data.length()

        source = Source.new()
        params = Array.new()

        %%write init;
        %%write exec;

        Message.new(source, command, params)

      end

    end
  end
end

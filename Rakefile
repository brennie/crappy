require 'rake/clean'

CLEAN.include('lib/crappy/irc/parser.rb')

task :default => ['lib/crappy/irc/parser.rb']

file 'lib/crappy/irc/parser.rb' => ['lib/crappy/irc/parser.rl'] do
  sh 'ragel -R -o lib/crappy/irc/parser.rb lib/crappy/irc/parser.rl'
end

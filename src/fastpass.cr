require "./fastpass/*"

module Fastpass
  {{ run "#{__DIR__}/parse_version.cr" }}
end

Fastpass::CLI.run

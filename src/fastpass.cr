require "./fastpass/*"

module Fastpass
  class MissingSha < Exception
  end

  {{ run "#{__DIR__}/parse_version.cr" }}
end

Fastpass::CLI.run

require "colorize"
require "http/client"
require "admiral"
require "../spec"
require "./helper"

class Fastpass::CLI::Files < Admiral::Command
  include Helper

  define_help description: "Runs a fast pass script."

  def run
    spec.parse_files(arguments.script).each do |file|
      puts file
    end
  end
end

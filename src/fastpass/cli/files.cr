require "colorize"
require "http/client"
require "admiral"
require "../spec"

class Fastpass::CLI::Files < Admiral::Command
  @spec : Spec?

  define_help description: "Runs a fast pass script."
  define_flag config, short: c, description: "Location of the config file", default: ".fastpass.yml"

  define_argument script : String, description: "The script to run", required: true

  def run
    spec.parse_files(arguments.script).each do |file|
      puts file
    end
  end

  private def spec
    @spec ||= Spec.from_yaml File.read(flags.config)
  end
end

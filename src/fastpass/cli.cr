require "admiral"

class Fastpass::CLI < Admiral::Command
  register_sub_command run : RunScript, description: "Run a fastpass script."
  register_sub_command check : CheckStatus, description: "Check a fastpass status."
  register_sub_command delete : DeleteStatus, description: "Delete a fastpass status."
  register_sub_command server : Server, description: "Run a fastpass server."
  register_sub_command files : Files, description: "List the watched files."

  define_version VERSION
  define_help description: "A script runner that will run only if changes have occurred."

  rescue_from Exception do |e|
    STDERR.puts(e.message.colorize(:red))
    Process.exit(1)
  end

  def run
    puts help
  end
end

require "./cli/*"

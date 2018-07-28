require "admiral"
class Fastpass::CLI < Admiral::Command
  register_sub_command run : RunScript, description: "Run a fastpass script."
  register_sub_command server : Server, description: "Run a fastpass server."

  define_help description: "A script runner that will run only if changes have occurred."

  def run
    puts help
  end
end

require "./cli/*"

require "admiral"
require "orion"
require "json"
require "../server"

class MissingSha < Exception
end

class Fastpass::CLI::Server < Admiral::Command
  define_help description: "Runs a fastpass server."
  define_flag redis : String
  define_flag fs : String
  define_flag memory : Bool

  def run
    Fastpass::Status.adapter = case flags
                     when .redis
                       Adapter::Redis.new flags.redis.to_s
                     when .fs
                       Adapter::FileStorage.new flags.fs.to_s
                     when .memory
                       Adapter::Memory.new
                     else
                       Adapter::Memory.new
                     end
    Fastpass::Server.listen(host: "0.0.0.0", port: (ENV["PORT"]? || 3000).to_i)
  end
end

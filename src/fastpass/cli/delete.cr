require "colorize"
require "http/client"
require "admiral"
require "./helper"

class Fastpass::CLI::DeleteStatus < Admiral::Command
  include Helper

  rescue_from Exception do |e|
    STDERR.puts(e.message.colorize(:red))
  end

  define_help description: "Deletes a fastpass status."
  define_argument sha : String, description: "The sha to delete"

  def run
    @sha = arguments.sha
    log "deleting sha: #{sha}", :magenta
    response = HTTP::Client.delete(uri.to_s)
    log "deleted #{sha}!"
  rescue e
    log "error: #{e.message}", :light_red, @error_io
  end
end

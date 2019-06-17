require "uri"
module Fastpass::CLI::ShaHelper

  @uri : URI?
  @sha : String?

  private def sha
    @sha ||= begin
      start = Time.now
      print "🐇  calculating sha".colorize(:cyan)
      sha = spec.compute_sha(script, arguments.to_a).to_s
      print ": #{sha}".colorize(:cyan)
      print " (took #{(Time.now - start).to_f.round(2)}s)\n"
      sha
    rescue e
      puts
      raise e
    end
  end

  private def log(message, color = :white, io = @output_io)
    io.puts "🐇  #{message}".colorize(color)
  end

  private def uri(params = nil)
    @uri ||= URI.parse(spec.server).tap do |uri|
      log "server: #{uri.to_s}"
      uri.path = "/#{sha}"
      uri.query = HTTP::Params.encode(params) if params
    end
  end
end

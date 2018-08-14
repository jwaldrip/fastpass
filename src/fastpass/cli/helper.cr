require "../spec"

module Fastpass::CLI::Helper
  @uri : URI?
  @spec : Spec?
  @sha : String?

  macro included
    define_flag config, short: c, description: "Location of the config file", default: ".fastpass.yml"
    define_argument script : String, description: "The script to run", required: true
  end

  private def spec
    @spec ||= Spec.from_yaml File.read(flags.config)
  end

  private def sha
    @sha ||= begin
      start = Time.now
      print "🐇  calculating sha".colorize(:cyan)
      sha = spec.compute_sha(arguments.script, arguments.to_a).to_s
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

  private def uri
    @uri ||= URI.parse(spec.server).tap do |uri|
      log "server: #{uri.to_s}"
      uri.path = "/#{sha}"
    end
  end
end

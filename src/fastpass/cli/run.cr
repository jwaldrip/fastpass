require "colorize"
require "http/client"
require "admiral"
require "../spec"

class Fastpass::CLI::RunScript < Admiral::Command
  @uri : URI?
  @spec : Spec?
  @sha : String?

  define_help description: "Runs a fast pass script."
  define_flag config, short: c, description: "Location of the config file", default: ".fastpass.yml"

  define_argument script : String, description: "The script to run", required: true

  def run
    check
  end

  private def check
    start = Time.now
    puts "🐇  server: #{spec.server}"
    print "🐇  calculating sha".colorize(:cyan)
    print ": #{sha}".colorize(:cyan)
    print " (took #{(Time.now - start).to_f.round(2)}s)\n"
    puts "🐇  checking status".colorize(:light_yellow)
    response = HTTP::Client.get uri
    raise "unknown status" unless response.status_code < 400
    fastpass
  rescue e
    @error_io.puts "🐇  error: #{e.message}".colorize(:light_red)
    run_and_report
  end

  private def fastpass
    puts "🐇  fastpass!".colorize(:light_green)
  end

  private def run_and_report
    puts "🐇  running command:".colorize(:light_green)
    puts ""
    input_io = IO::Memory.new.tap do |io|
      spec.full_command.lines.each do |line|
        puts "    " + line
        io.puts line
      end
      io.rewind
    end
    puts ""
    status = Process.run(
      command: ENV["SHELL"],
      args: ["-eo", "pipefail"],
      input: input_io,
      error: @error_io,
      output: @output_io
    )
    status.success? ? report : Process.exit(status.exit_status)
  end

  private def report
    puts ""
    puts "🐇  reporting success".colorize(:light_green)
    response = HTTP::Client.post uri
    raise "unable to report" unless response.status_code == 201
  rescue e
    @error_io.puts "🐇  error: #{e.message}".colorize(:light_red)
  end

  private def spec
    @spec ||= Spec.from_yaml File.read(flags.config)
  end

  private def sha
    @sha ||= spec.compute_sha(arguments.script, arguments.to_a).to_s
  end

  private def uri
    @uri ||= URI.parse(spec.server).tap do |uri|
      uri.path = "/#{sha}"
    end
  end
end

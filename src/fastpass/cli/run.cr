require "colorize"
require "http/client"
require "admiral"
require "./helper"

class Fastpass::CLI::RunScript < Admiral::Command
  include Helper
  @runtime : Float64?

  class UnknownStatus < Exception
  end

  rescue_from Exception do |e|
    log e.message, :light_red, @error_io
    Process.exit(1)
  end

  define_help description: "Runs a fastpass script."
  define_flag shell, short: s, description: "the shell to run in", default: "/bin/bash"
  define_flag shell_args, short: a, description: "arguments passed to the shell", default: "-leo pipefail"

  def run
    start = Time.now
    check
  end

  private def check
    log "checking status", :light_yellow
    response = HTTP::Client.get uri
    raise UnknownStatus.new("status unreported") unless response.status_code == 202
    timesaved = JSON.parse(response.body)["timesaved"].as_f
    log "fastpass (saved #{timesaved.round(2)}s)!", :light_green
  rescue e : UnknownStatus
    log "#{e.message}", :light_yellow, @error_io
    run_and_report
  rescue e
    log "#{e.message}, status wont be reported", :light_red, @error_io
    run_command
  end

  private def run_and_report
    run_command
    report
  end

  private def run_command
    log "running command:", :light_green
    puts ""
    input_io = IO::Memory.new.tap do |io|
      spec.full_command.lines.each do |line|
        puts "    " + line
        io.puts line
      end
      io.rewind
    end
    puts ""
    start = Time.now
    status = Process.run(
      command: flags.shell,
      args: flags.shell_args.split(" "),
      input: input_io,
      error: @error_io,
      output: @output_io
    )
    @runtime = (Time.now - start).to_f
    raise "command failed" unless status.success?
  end

  private def report
    puts ""
    log "reporting success", :light_green
    response = HTTP::Client.post(uri.to_s, form: {"runtime" => @runtime.to_s})
    raise "unable to report" unless response.status_code == 201
  end
end

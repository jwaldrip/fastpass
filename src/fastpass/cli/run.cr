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
    log "running script \"#{arguments.script}\"", :light_green
    puts ""
    File.tempfile arguments.script do |file|
      lines = spec.full_command.lines
      lines.unshift "#!/bin/bash -le" unless lines[0]? =~ /^#!\/.+/
      lines.each do |line|
        puts "    " + line
        file.puts line
      end
      start = Time.now
      File.chmod(file.path, 0o755)
      file.close
      puts "", "---------- command output ----------", ""
      status = Process.run(
        command: file.path,
        input: @input_io,
        error: @error_io,
        output: @output_io
      )
      @runtime = (Time.now - start).to_f
      raise "command failed" unless status.success? || status.signal_exit?
    end    
  end

  private def report
    puts ""
    log "reporting success", :light_green
    response = HTTP::Client.post(uri.to_s, form: {"runtime" => @runtime.to_s})
    raise "unable to report" unless response.status_code == 201
  end
end

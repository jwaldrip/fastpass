require "uri"
require "openssl/digest"
require "set"
require "yaml"

class Fastpass::Spec
  getter full_command = ""
  @environment = {} of String => String
  @files = Set(String).new
  @static_ignore_files = [] of String

  YAML.mapping({
    server:            {type: String, default: "https://fastpass.rocks"},
    check_outputs:     Array(String),
    check_files:       {type: Array(String), default: [] of String},
    check_environment: {type: Array(String), default: [] of String},
    ignore_files:      {type: Array(String), default: [] of String},
    scripts:           Hash(String, String | Script),
  })

  def parse_files(script_name : String)
    return @files unless @files.empty?
    script = @scripts[script_name]? || raise "script does not exist: #{script_name}"
    include_files(script)
    ignore_files(script)
    parse_ignore_file ".fastpassignore"
    @files
  end

  def compute_sha(script_name : String, args : Array(String))
    script = @scripts[script_name]? || raise "script does not exist: #{script_name}"

    # Set it all up
    include_environment(script)
    parse_files(script_name)

    # Actually compute the sha
    OpenSSL::Digest.new("sha256").tap do |sha|
      compute_command(sha, script, args)
      compute_files(sha)
      compute_environment(sha)
      compute_outputs(sha, script)
    end
  end

  private def compute_command(sha, script : Script, args : Array(String))
    compute_command(sha, script.@command, args)
  end

  private def compute_command(sha, command : String, args : Array(String))
    raise "Cannot have arguments with multiline scripts" if (command.lines.size > 1 && args.size > 0)
    @full_command = ([command] + args).join(" ")
    sha.update @full_command
  end

  private def compute_outputs(sha, script : String)
    ((@check_outputs || [] of String)).each do |command|
      compute_output sha, script, command
    end
  end

  private def compute_outputs(sha, script : Script)
    ((@check_outputs || [] of String) + (script.@check_outputs || [] of String)).each do |command|
      compute_output sha, script, command
    end
  end

  private def compute_output(sha, script, command : String)
    sha.update `#{command}`
  end

  private def compute_files(sha)
    @files.to_a.sort.each do |file|
      sha.update File.read(file)
    end
  end

  private def compute_environment(sha)
    @environment.each do |k, v|
      env = [k, v].join("=")
      sha.update env
    end
  end

  private def include_environment(script : Script)
    include_environment
    include_environment(script.@check_environment)
  end

  private def include_environment(script : String? = nil)
    include_environment(@check_environment)
  end

  private def include_environment(envs : Array(String))
    envs.each do |env|
      @environment[env] = ENV[env]?.to_s
    end
  end

  private def include_files(script : Script)
    include_files
    include_files(script.@check_files)
  end

  private def include_files(script : String? = nil)
    include_files(@check_files)
  end

  private def include_files(matches : Array(String))
    matches = expand_matches(matches)
    Dir.glob(matches, true).each do |file|
      if File.directory?(file)
        @static_ignore_files << File.expand_path(".fastpassignore", file)
      else
        begin
          @static_ignore_files << file if File.basename(file) == ".fastpassignore"
          @files.add File.real_path(file)
        rescue e : Errno
        end
      end
    end
  end

  private def ignore_files(script : Script)
    ignore_files
    ignore_files(script.@ignore_files)
    @static_ignore_files.each do |file|
      parse_ignore_file file
    end
  end

  private def ignore_files(script : String? = nil)
    ignore_files(@ignore_files)
  end

  private def ignore_files(matches : Array(String))
    matches << ".git"
    matches = expand_matches(matches)
    Dir.glob(matches, true).each do |file|
      unless File.directory?(file)
        begin
          @files.delete File.real_path(file)
        rescue e : Errno
        end
      end
    end
  end

  private def expand_matches(matches : Array(String), dir = Dir.current)
    matches.map do |match|
      path = if File.directory?(File.expand_path(match, dir))
               "#{match}/**/*"
             elsif match =~ /^\.?\.?\//
               match
             else
               "./**/#{match}"
             end
      File.expand_path(path, dir)
    end.compact
  end

  private def parse_ignore_file(ignore_file)
    if File.exists?(ignore_file)
      ignore_file = File.expand_path(ignore_file)
      path = File.dirname(ignore_file)
      ignored_files = File.read(ignore_file).lines.map { |f| File.join(path, f.strip) }.reject(&.empty?)
      ignore_files(ignored_files)
    end
  end
end

require "./spec/*"

require "uri"
require "openssl/digest"
require "set"
require "yaml"

class Fastpass::Spec
  getter full_command = ""
  @environment = {} of String => String
  @files = Set(String).new

  YAML.mapping({
    server: { type: String, default: "https://fastpass.rocks" },
    check_files: { type: Array(String), default: [] of String },
    check_environment: { type: Array(String), default: [] of String },
    ignore_files: { type: Array(String), default: [] of String },
    scripts: Hash(String, String | Script)
  }, true)

  def compute_sha(script_name : String, args : Array(String))
    script = scripts[script_name]? || raise "script does not exist: #{script_name}"

    # Set it all up
    include_environment(script)
    include_files(script)
    ignore_files(script)

    # Actually compute the sha
    OpenSSL::Digest.new("sha256").tap do |sha|
      compute_command(sha, script, args)
      compute_files(sha)
      compute_environment(sha)
    end
  end

  private def compute_command(sha, script : Script, args : Array(String))
    compute_command(sha, script.@command, args)
  end

  private def compute_command(sha, command : String, args : Array(String))
    @full_command = ([command] + args).join(" ")
    sha.update full_command
  end

  private def compute_files(sha)
    @files.each do |file|
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

  private def include_files(files : Array(String))
    Dir.glob(files, true).each do |file|
      begin
        path = File.real_path(File.expand_path(file))
        @files.add path unless File.directory?(path)
      rescue e : Errno
      end
    end
  end

  private def ignore_files(script : Script)
    ignore_files
    ignore_files(script.@ignore_files)
  end

  private def ignore_files(script : String? = nil)
    ignore_files(@ignore_files)
  end

  private def ignore_files(files : Array(String))
    files << "./.git/**/*"
    Dir.glob(files, true).each do |file|
      path = File.real_path(File.expand_path(file))
      @files.delete path unless File.directory?(path)
    end
  end

end

require "./spec/*"

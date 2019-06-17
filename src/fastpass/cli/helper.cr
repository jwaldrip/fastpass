require "../spec"
require "./sha_helper"

module Fastpass::CLI::Helper
  include ShaHelper

  @spec : Spec?

  macro included
    define_flag config, short: c, description: "Location of the config file", default: ".fastpass.yml"
    define_argument script : String, description: "The script to run", required: true
  end

  private def script
    arguments.script
  end

  private def spec
    @spec ||= Spec.from_yaml File.read(flags.config)
  end
end

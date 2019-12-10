require "yaml"

class Fastpass::Spec::Script
  YAML.mapping(
    command: String,
    retries: {type: Int32, default: 0},
    check_outputs: {type: Array(String), default: [] of String},
    check_files: {type: Array(String), default: [] of String},
    check_environment: {type: Array(String), default: [] of String},
    ignore_files: {type: Array(String), default: [] of String}
  )
end

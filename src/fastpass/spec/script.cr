require "yaml"

class Fastpass::Spec::Script
  YAML.mapping(
    command: String,
    check_files: {type: Array(String), default: [] of String},
    check_environment: {type: Array(String), default: [] of String},
    ignore_files: {type: Array(String), default: [] of String}
  )
end

require "yaml"

class Fastpass::Spec::Script
  YAML.mapping(
    command: String,
    check_files: Array(String),
    ignore_files: Array(String),
    check_environment: Array(String)
  )
end

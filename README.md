# fastpass

Ensure CI doesn't run more than it needs to by "fast-passing" your commands.

## Installation

### Homebrew

`brew install jwaldrip/on-tap/fastpass`

### Linux

`curl -fsSL https://raw.githubusercontent.com/jwaldrip/fastpass/master/install-nix.sh`

## Usage

Fastpass comes in two parts, a reporting server and a script runner. You will
need to run your server and then configure your script runner locally by creating
a `fastpass.yml` file.

Here is the spec:

```yaml
# The server we will be reporting to (defaults to https://fastpass.rocks)
server: "http://fastpass.jasonwaldrip.com"
# Environment vars to include in the sha (optional)
check_environment:
  - FOO
# Files to include in the sha (optional)
check_files:
  - "./**/*"
# Files to ignore in the sha (optional)
ignore_files:
  - "./ignored-file"
# A list of scripts to be run with `fastpass run` (required)
scripts:
  # A shorthand script, by the name of run and running the command `crystal run ./main.cr`
  run: crystal run ./main.cr

  # A longhand script, by the name of spec, running the command `crystal spec`, and specifying additional environment vars and files.
  spec:
    command: crystal spec
    check_environment:
      - BAR
    check_files:
      - "./spec/**/*"
    ignore_files:
      - "./other-ignored-file"
```

### Running the Server

```sh
$ fastpass server
```

### Running a script

```sh
$ fastpass run [script]
```

## Contributing

1. Fork it (<https://github.com/jwaldrip/fastpass/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [jwaldrip](https://github.com/jwaldrip) Jason Waldrip - creator, maintainer

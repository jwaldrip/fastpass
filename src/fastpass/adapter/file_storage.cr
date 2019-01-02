require "file_utils"

class Fastpass::Adapter::FileStorage
    @path : String

    def initialize(path : String)
        @path = File.expand_path(path)
        FileUtils.mkdir_p(@path)
        increment_total(0.0)
    end

    def report(sha : String, runtime : Float64)
        File.open(path_to(sha), "w+") do |io|
            io.puts runtime.to_s
        end
    end

    def check(sha : String, increment = true)
        path = path_to(sha)
        value = File.exists?(path) ? File.read(path).strip : nil
        raise MissingSha.new unless value
        increment_total(value.to_f) if increment
        value
    end

    def get_total
        File.read(path_to("total")).strip.to_f
    end

    def delete(sha : String) : Nil
        File.delete path_to(sha)
    rescue
        nil
    end

    private def increment_total(amount : Float64)
        path = path_to("total")
        value = File.exists?(path) ? File.read(path).strip.to_f : 0.0
        File.open(path, "w+") do |io|
            new_value = value + amount
            io.print new_value.to_s
        end
    end

    private def path_to(name : String)
        File.join(@path, name)
    end
end
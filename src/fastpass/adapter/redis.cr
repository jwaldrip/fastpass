require "redis"

class Fastpass::Adapter::Redis
    TOTAL_KEY = "total_saved"

    def initialize(url : String)
        @client = ::Redis.new(url: url)
        increment_total 0.0
    end

    def report(sha : String, runtime : Float64)
        @client.set(sha, runtime)
    end

    def check(sha : String, increment = true)
        value = @client.get(sha)
        raise MissingSha.new unless value
        increment_total(value.to_f) if increment
        value.to_f
    end

    def get_total
        @client.get(TOTAL_KEY).try(&.to_f) || 0.0
    end

    def delete(sha : String)
        @client.del sha
    end

    private def increment_total(amount : Float64)
        @client.set(TOTAL_KEY, get_total + amount)
    end
end
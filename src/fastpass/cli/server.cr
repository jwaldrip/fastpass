require "admiral"
require "orion"
require "json"
require "../adapter/*"

class MissingSha < Exception
end

class Fastpass::CLI::Server < Admiral::Command
  class_property adapter : Adapter::Redis | Adapter::FileStorage | Adapter::Memory = Adapter::Memory.new

  define_help description: "Runs a fastpass server."
  define_flag redis : String
  define_flag fs : String
  define_flag memory : Bool

  router App do
    use HTTP::ErrorHandler
    use HTTP::LogHandler

    get "/" do |context|
      context.response.puts "Time Saved: #{Server.adapter.get_total.round(2)}s"
    end

    get "/:sha" do |context|
      sha = context.request.path_params["sha"]
      context.response.status_code = 202
      context.response.content_type = "application/json"
      JSON.build(context.response) do |builder|
        timesaved = Server.adapter.check sha, context.request.query_params["check"]? != "true"
        {timesaved: timesaved}.to_json(builder)
      end
    rescue MissingSha
      context.response.status_code = 404
    end

    post "/:sha" do |context|
      form_params = HTTP::Params.parse(context.request.body.try(&.gets_to_end).to_s)
      sha = context.request.path_params["sha"]
      Server.adapter.report sha, (form_params["runtime"]? || 0.0).to_f
      context.response.status_code = 201
    end

    delete "/:sha" do |context|
      Server.adapter.delete context.request.path_params["sha"]
    end
  end

  def run
    Server.adapter = case flags
                     when .redis
                       Adapter::Redis.new flags.redis.to_s
                     when .fs
                       Adapter::FileStorage.new flags.fs.to_s
                     when .memory
                       Adapter::Memory.new
                     else
                       Adapter::Memory.new
                     end
    App.listen(host: "0.0.0.0", port: (ENV["PORT"]? || 3000).to_i)
  end
end

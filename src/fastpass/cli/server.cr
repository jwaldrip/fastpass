require "admiral"
require "orion"
require "json"

class Fastpass::CLI::Server < Admiral::Command
  SHAS = {} of String => Float64

  class_property saved : Float64 = 0.0

  define_help description: "Runs a fast pass server."

  router App do
    use HTTP::ErrorHandler
    use HTTP::LogHandler

    get "/" do |context|
      context.response.puts "Time Saved: #{Server.saved.round(2)}s"
    end

    get "/:sha" do |context|
      sha = context.request.path_params["sha"]
      if SHAS[sha]?
        context.response.status_code = 202
        context.response.content_type = "application/json"
        JSON.build(context.response) do |builder|
          Server.saved += SHAS[sha]
          {timesaved: SHAS[sha]}.to_json(builder)
        end
      else
        context.response.status_code = 404
      end
    end

    post "/:sha" do |context|
      form_params = HTTP::Params.parse(context.request.body.try(&.gets_to_end).to_s)
      sha = context.request.path_params["sha"]
      SHAS[sha] = (form_params["runtime"]? || 0.0).to_f
      context.response.status_code = 201
    end
  end

  def run
    App.listen(host: "0.0.0.0", port: (ENV["PORT"]? || 3000).to_i)
  end
end

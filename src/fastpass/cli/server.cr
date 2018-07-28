require "admiral"
require "orion"

class Fastpass::CLI::Server < Admiral::Command
  SHAS = {} of String => Bool

  define_help description: "Runs a fast pass server."

  router App do
    use HTTP::ErrorHandler
    use HTTP::LogHandler

    get "/:sha" do |context|
      sha = context.request.path_params["sha"]
      context.response.status_code = SHAS[sha]? ? 200 : 404
    end

    post "/:sha" do |context|
      sha = context.request.path_params["sha"]
      SHAS[sha] = true
      context.response.status_code = 201
    end
  end

  def run
    App.listen(port: (ENV["PORT"]? || 3000).to_i)
  end
end

router Fastpass::Server do
  use HTTP::ErrorHandler
  use HTTP::LogHandler

  get "/", to: "status#stats"
  get "/:sha", to: "status#view"
  post "/:sha", to: "status#update"
  delete "/:sha", to: "status#delete"
  # get "/:artifacts", to: "status#get_artifacts", format: "zip"
  # post "/:artifacts", to: "status#store_artifacts", format: "zip"
end

require "./models/**"
require "./controllers/**"

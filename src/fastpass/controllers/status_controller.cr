class Fastpass::StatusController < Fastpass::Server::BaseController
  def stats
    response.puts "Time Saved: #{Fastpass::Status.adapter.get_total.round(2)}s"
  end

  def view
    timesaved = status.check context.request.query_params["check"]? != "true"
    response.status_code = 202
    response.content_type = "application/json"
    JSON.build(response) do |builder|
      {timesaved: timesaved}.to_json(builder)
    end
  rescue MissingSha
    context.response.status_code = 404
  end

  def update
    form_params = HTTP::Params.parse(request.body.try(&.gets_to_end).to_s)
    status.report (form_params["runtime"]? || 0.0).to_f
    response.status_code = 201
  end

  def delete
    status.delete
  end

  private def status
    sha = request.path_params["sha"]
    Fastpass::Status.new(sha)
  end
end

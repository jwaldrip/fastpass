require "../adapter/**"

class Fastpass::Status
  class_property adapter : Adapter::Redis | Adapter::FileStorage | Adapter::Memory = Adapter::Memory.new

  def initialize(@sha : String)
  end

  def report(time_saved : Float)
    self.class.adapter.report @sha, time_saved
  end

  def check(update_stats : Bool)
    self.class.adapter.check @sha, update_stats
  end

  def delete
    self.class.adapter.delete @sha
  end
end

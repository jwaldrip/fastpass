class Fastpass::Adapter::Memory
  def initialize
    @total = 0.0
    @shas = {} of String => Float64
  end

  def report(sha : String, runtime : Float64)
    @shas[sha] = runtime
  end

  def check(sha : String, increment = true)
    value = @shas[sha]?
    raise MissingSha.new unless value
    increment_total(value) if increment
    value.to_f
  end

  def get_total
    @total
  end

  def delete(sha : String)
    @shas.delete sha
  end

  private def increment_total(amount : Float64)
    @total += amount
  end
end

class Contract
  attr_reader :specs

  def initialize(name)
    @name = name
    @specs = {}
  end
end
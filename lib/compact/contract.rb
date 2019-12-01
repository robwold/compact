require_relative './spec'
class Contract
  attr_reader :specs

  def initialize(name)
    @name = name
    @specs = []
  end

  def add_spec(method:, args:, returns:)
    @specs.push Spec.new(method: method, args: args, returns: returns)
  end

  def unverified_specs
    @specs.reject{|spec| spec.verified?}
  end

  def verified_specs
    @specs.select{|spec| spec.verified? }
  end
end
class Spec
  attr_reader :method, :args, :returns
  def initialize(args:, method:, returns:)
    @method = method
    @args = args
    @returns = returns
    @verified = false
  end

  def verified?
    @verified
  end
end
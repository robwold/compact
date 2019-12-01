class Spec
  attr_reader :method, :args, :returns
  def initialize( method:, args:,  returns:)
    @method = method
    @args = args
    @returns = returns
    @verified = false
  end

  def verified?
    @verified
  end

  def == other_spec
    same_args = args == other_spec.args
    same_method = method == other_spec.method
    same_returns = returns == other_spec.returns
    same_args && same_method && same_returns
  end
end
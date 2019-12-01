class Spec

  def initialize(method:,args:, returns:)
    @method = method,
    @args = args,
    @returns = returns
    @verified = false
  end

  def verified?
    @verified
  end
end
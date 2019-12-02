class ArgumentInterceptor < SimpleDelegator
  attr_accessor :invocations

  def initialize(delegate)
    @invocations = {}
    super
  end

  def method_missing(method, *args, &block)
    @invocations[method] ||= []
    returns = super
    @invocations[method].push({args: args, returns: returns})
    returns
  end
end

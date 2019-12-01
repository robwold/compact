class ArgumentInterceptor < SimpleDelegator
  attr_accessor :invocations

  def initialize(delegate)
    @invocations = {}
    super
  end

  def method_missing(method, *args, &block)
    @invocations[method] ||= []
    result = super
    @invocations[method].push({args: args, result: result})
    result
  end
end
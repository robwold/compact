class ArgumentInterceptor < SimpleDelegator
  attr_accessor :invocations

  def initialize(delegate)
    @invocations = {}
    super
  end

  def method_missing(method, *args, &block)
    @invocations[method] ||= []
    @invocations[method].push args
    super
  end
end
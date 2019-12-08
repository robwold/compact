module Compact
  class ArgumentInterceptor < SimpleDelegator
    attr_accessor :invocations

    def initialize(delegate)
      @invocations = []
      super
    end

    def method_missing(method, *args, &block)
      returns = super
      @invocations.push(Invocation.new(method: method, args: args, returns: returns))
      returns
    end
  end
end

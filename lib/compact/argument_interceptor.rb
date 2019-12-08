module Compact
  class ArgumentInterceptor < SimpleDelegator
    attr_accessor :invocations

    def initialize(delegate)
      @invocations = []
      super
    end

    def method_missing(method, *args, &block)
      # @invocations[method] ||= []
      returns = super
      @invocations.push(Invocation.new(method: method, args: args, returns: returns))
      returns
    end

    def invocations_for_method(method)
      @invocations.select{|inv| inv.method == method }
    end
  end
end

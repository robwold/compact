module Compact
  class ArgumentInterceptor < SimpleDelegator
    attr_accessor :invocations

    def initialize(delegate)
      @invocations = []
      @contract = nil
      super
    end

    def register(contract)
      @contract = contract
    end

    def method_missing(method, *args, &block)
      returns = super
      invocation = Invocation.new(method: method, args: args, returns: returns)
      @invocations.push(invocation)
      @contract.add_invocation(invocation) if @contract
      returns
    end
  end
end

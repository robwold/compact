module Compact
  class Invocation
    attr_reader :method, :args, :returns
    def initialize( method:, args:,  returns:)
      @method = method
      @args = args
      @returns = returns
    end

    def == other_invocation
      same_args = args == other_invocation.args
      same_method = method == other_invocation.method
      same_returns = returns == other_invocation.returns
      same_args && same_method && same_returns
    end
  end
end
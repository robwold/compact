module Compact
  class Invocation
    attr_reader :method, :args, :returns
    def initialize( method:, args:,  returns:)
      @method = method
      @args = args
      @returns = returns
    end

    def == other_invocation
      same_returns = returns == other_invocation.returns
      matches_call(other_invocation) && same_returns
    end

    def eql? other_invocation
      self.== other_invocation
    end

    def hash
      describe.hash
    end

    def matches_call(other_invocation)
      same_args = args == other_invocation.args
      same_method = method == other_invocation.method
      same_args && same_method
    end

    def describe
      <<~DESCRIPTION
      method: #{method}
      invoke with: #{args.inspect}
      returns: #{returns}
      DESCRIPTION
    end
  end
end
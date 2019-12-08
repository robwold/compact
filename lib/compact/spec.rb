module Compact
  class Spec
    attr_reader :method, :args, :returns
    def initialize( method:, args:,  returns:, verified: false, pending: false)
      @method = method
      @args = args
      @returns = returns
      @verified = verified
      @pending = pending
    end

    def verified?
      @verified
    end

    def verify
      @verified = true
    end

    def pending?
      @pending
    end

    def == other_spec
      same_args = args == other_spec.args
      same_method = method == other_spec.method
      same_returns = returns == other_spec.returns
      same_args && same_method && same_returns
    end
  end
end
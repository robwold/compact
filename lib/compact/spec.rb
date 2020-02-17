module Compact
  class Spec
    attr_reader :invocation
    attr_accessor :verified, :pending

    def initialize(invocation:, verified: false, pending: false)
      @invocation = invocation
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
      invocation == other_spec.invocation
    end
  end
end
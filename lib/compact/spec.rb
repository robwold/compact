module Compact
  class Spec
    attr_reader :invocation
    attr_accessor :verified, :pending

    def initialize(invocation:, pending: false)
      @invocation = invocation
      @pending = pending
      @status_code = nil
    end

    def verified?
      @status_code == :verified
    end

    def verify
      @status_code = :verified
    end

    def pending?
      @pending
    end

    def == other_spec
      invocation == other_spec.invocation
    end
  end
end
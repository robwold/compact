module Compact
  class Spec
    attr_reader :invocation

    def initialize(invocation:, pending: false)
      @invocation = invocation
      @status_code = pending ? :pending : nil
    end

    def verified?
      @status_code == :verified
    end

    def verify
      @status_code = :verified
    end

    def pending?
      @status_code == :pending
    end

    def pending!
      @status_code = :pending
    end

    def == other_spec
      invocation == other_spec.invocation
    end
  end
end
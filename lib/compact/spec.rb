module Compact
  class Spec
    attr_reader :invocation

    def initialize(invocation, status_code = UNTESTED)
      @invocation = invocation
      @status_code = status_code
    end

    def untested?
      @status_code == :untested
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

    def failing?
      @status_code == :failing
    end

    def failing!
      @status_code = :failing
    end

    def == other_spec
      invocation == other_spec.invocation
    end
  end
end
require_relative './spec'
require_relative './argument_interceptor'
require_relative './invocation'
module Compact
  class Contract
    attr_reader :specs

    def initialize(name)
      @name = name
      @specs = []
    end

    def add_spec(invocation:, verified: false, pending: false)
      @specs.push Spec.new(invocation: invocation, verified: verified, pending: pending)
    end

    def unverified_specs
      @specs.reject(&:verified?)
    end

    def verified_specs
      @specs.select(&:verified?)
            .reject(&:pending?)
    end

    def pending_specs
      @specs.select(&:pending?)
    end

    def verify(collaborator)
      interceptor = ArgumentInterceptor.new(collaborator)
      yield(interceptor)
      compare_to_specs interceptor.invocations
    end

    private
    def specs_matching(invocations)
      @specs.select {|spec| matches_invocation?(spec, invocations) }
    end

    def matches_invocation?(spec, invocations)
      invocations.any?{|invocation| invocation.matches_call(spec.invocation)}
    end

    def matches_exactly?(spec, invocations)
      invocations.any?{|invocation| invocation == spec.invocation }
    end

    def compare_to_specs(invocations)
      possible_matches = specs_matching(invocations)
      if possible_matches.empty?
        add_pending_specs(invocations)
        return PENDING
      end
      verified_spec = possible_matches.find{|spec| matches_exactly?(spec, invocations) }
      if verified_spec
        verified_spec.verify
        VERIFIED
      else
        FAILING
      end
    end

    def add_pending_specs(invocations)
      invocations.each do |invocation|
        add_spec(invocation: invocation,
                 verified: true,
                 pending: true)
      end
    end
  end
end
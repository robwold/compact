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
      possible_matches = specs_matching_invocation(interceptor)

      if possible_matches.empty?
        interceptor.invocations.each do |invocation|
            add_spec(invocation: invocation,
                     verified: true,
                     pending: true)
        end
        return PENDING
      end
      verified_spec = possible_matches.find{|spec| matches_exactly?(spec, interceptor) }
      if verified_spec
        verified_spec.verify
        VERIFIED
      else
        FAILING
      end
    end

    private
    def specs_matching_invocation(interceptor)
      @specs.select {|spec| matches_invocation?(spec, interceptor) }
    end

    def matches_invocation?(spec, interceptor)
      invocations = interceptor.invocations_for_method(spec.method)
      invocations&.any?{|invocation| invocation.args == spec.args  }
    end

    def matches_exactly?(spec, interceptor)
      invocations = interceptor.invocations_for_method(spec.method)
      invocations&.any?{|invocation| invocation == spec.invocation }
    end
  end
end
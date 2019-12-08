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

    def add_spec(method:, args:, returns:, verified: false, pending: false)
      invocation = Invocation.new(method: method, args: args, returns: returns)
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
        interceptor.invocations.each do |method_name, method_invocations|
          method_invocations.each do |method_invocation|
            add_spec(method: method_name,
                     args: method_invocation[:args],
                     returns: method_invocation[:returns],
                     verified: true,
                     pending: true)
          end
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
      invocations = interceptor.invocations[spec.method]
      return false unless invocations
      invocations.any?{|invocation| invocation[:args] == spec.args  }
    end

    def matches_exactly?(spec, interceptor)
      invocations = interceptor.invocations[spec.method]
      return false unless invocations
      invocations.any?{|invocation| invocation[:args] == spec.args && invocation[:returns] == spec.returns }
    end
  end
end
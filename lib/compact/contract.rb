require_relative './spec'
require_relative './argument_interceptor'
require_relative './invocation'
module Compact
  class Contract
    attr_reader :specs

    def initialize
      @specs = []
    end

    def add_spec(invocation:, verified: false, pending: false)
      @specs.push Spec.new(invocation: invocation, verified: verified, pending: pending)
    end

    def verified?
      unverified_invocations.empty? && pending_invocations.empty?
    end

    def describe_unverified_specs
      banner = "================================================================================"
      <<~MSG
      The following methods were invoked on test doubles without corresponding contract tests:
      #{banner}
      #{unverified_invocations.map(&:describe)
                              .join(banner).strip}
      #{banner}
      MSG
    end

    def unverified_invocations
      @specs.reject(&:verified?).map(&:invocation)
    end

    def verified_invocations
      @specs.select(&:verified?)
            .reject(&:pending?).map(&:invocation)
    end

    def pending_invocations
      @specs.select(&:pending?).map(&:invocation)
    end

    def verify(collaborator, block = Proc.new)
      interceptor = ArgumentInterceptor.new(collaborator)
      block.call(interceptor)
      compare_to_specs interceptor.invocations
    end

    def watch(test_double)
      this = self
      original_verbosity = $VERBOSE
      $VERBOSE = nil
      instance_method_names = test_double.methods - Object.new.methods
      instance_method_names.each do |name|
        real_method = test_double.method(name)
        test_double.define_singleton_method(name) do |*args, &block|
          return_value = real_method.call(*args, &block)
          invocation = Invocation.new(method: name, args: args, returns: return_value)
          matching_invocation = this.pending_invocations.find{|inv| inv == invocation}
          if matching_invocation
            matching_spec = this.specs.find{|spec| spec.pending? && spec.invocation == invocation }
            matching_spec.verified = true
            matching_spec.pending = false
          else
            this.add_spec(invocation: invocation)
          end

          return_value
        end
      end
      $VERBOSE = original_verbosity
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
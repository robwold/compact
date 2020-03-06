require_relative './spec'
require_relative './argument_interceptor'
require_relative './invocation'
module Compact
  class Contract
    attr_reader :specs

    def initialize
      @specs = []
    end

    ## ========PUBLIC API: used in non-test code===================
    def watch(test_double)
      contract = self
      original_verbosity = $VERBOSE
      $VERBOSE = nil
      instance_method_names = test_double.methods - Object.new.methods
      instance_method_names.each do |name|
        real_method = test_double.method(name)
        test_double.define_singleton_method(name) do |*args, &block|
          return_value = real_method.call(*args, &block)
          contract.add_invocation Invocation.new(method: name, args: args, returns: return_value)
          return_value
        end
      end
      $VERBOSE = original_verbosity
    end

    def verified?
      untested_invocations.empty? && pending_invocations.empty?
    end

    def has_pending?
      !pending_invocations.empty?
    end

    def has_untested?
      !untested_invocations.empty?
    end

    def describe_untested_specs
      banner = "================================================================================"
      <<~MSG
      The following methods were invoked on test doubles without corresponding contract tests:
      #{banner}
      #{untested_invocations.map(&:describe)
                           .join(banner).strip}
      #{banner}
      MSG
    end

    def describe_pending_specs
      banner = "================================================================================"
      <<~MSG
      No test doubles mirror the following verified invocations:
      #{banner}
      #{pending_invocations.map(&:describe)
                           .join(banner).strip}
      #{banner}
      MSG
    end

    def verify(collaborator, block = Proc.new)
      interceptor = ArgumentInterceptor.new(collaborator)
      block.call(interceptor)
      compare_to_specs interceptor.invocations
    end

    # ============= QUASI-private==============
    #
    # These methods are only used by #watch, BUT
    # we're defining methods on the watched object that
    # invoke these as public methods.

    def add_invocation(invocation)
      matching_invocation = pending_invocations.find{|inv| inv == invocation}
      if matching_invocation
        matching_spec = specs.find{|spec| spec.pending? && spec.invocation == invocation }
        matching_spec.verify
      else
        add_spec(invocation)
      end
    end

    private

    def untested_invocations
      @specs.reject(&:verified?).reject(&:pending?).map(&:invocation)
    end

    def verified_invocations
      @specs.select(&:verified?)
            .reject(&:pending?).map(&:invocation)
    end

    def pending_invocations
      @specs.select(&:pending?).map(&:invocation)
    end

    def add_spec(invocation, status_code = UNTESTED)
      @specs.push Spec.new(invocation, status_code)
    end

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
        add_spec(invocation, PENDING)
      end
    end
  end
end
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
      unverified_invocations.empty?
    end

    def has_pending?
      !pending_invocations.empty?
    end

    def has_untested?
      !untested_invocations.empty?
    end

    def has_failing?
      !failing_invocations.empty?
    end

    def describe_untested_specs
      headline = "The following methods were invoked on test doubles without corresponding contract tests:"
      messages = untested_invocations.map(&:describe)
      print_banner_separated(headline, messages)
    end

    def describe_pending_specs
      headline = "No test doubles mirror the following verified invocations:"
      messages = pending_invocations.map(&:describe)
      print_banner_separated(headline, messages)
    end

    def describe_failing_specs
      puts "failing: #{failing_invocations.inspect}"
      puts "untested: #{untested_invocations.inspect}"
      puts "pending: #{failing_invocations.inspect}"
      headline = "Attempts to verify the following method invocations failed:"
      messages = failing_invocations.map do |invocation|
        bad_results = pending_invocations.select{|p| p.matches_call(invocation) }
        invocation.describe.gsub("returns", "expected") +
            "\nMatching invocations returned the following values: #{bad_results.map(&:returns).inspect}"
      end
      print_banner_separated(headline, messages)
    end

    def verify(collaborator, block = Proc.new)
      interceptor = ArgumentInterceptor.new(collaborator)
      block.call(interceptor)
      compare_to_specs interceptor.invocations
    end

    # ============= QUASI-private ==============
    #
    # This methods is only used by #watch, BUT
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

    def unverified_invocations
      @specs.reject(&:verified?).map(&:invocation)
    end

    def untested_invocations
      @specs.select(&:untested?).map(&:invocation)
    end

    def pending_invocations
      @specs.select(&:pending?).map(&:invocation)
    end

    def failing_invocations
      @specs.select(&:failing?).map(&:invocation)
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
      # possible_matches = specs_matching(invocations)
      # if possible_matches.empty?
      #   add_pending_specs(invocations)
      # end
      # verified_spec = possible_matches.find{|spec| matches_exactly?(spec, invocations) }
      # if verified_spec
      #   verified_spec.verify
      # else
      #   possible_matches.each(&:failing!)
      # end
      verified_spec = @specs.find{|spec| matches_exactly?(spec, invocations) }
      if verified_spec
        verified_spec.verify
      else
        possible_matches = specs_matching(invocations)
        puts "possible matches: #{possible_matches.inspect}"
        puts "adding invocations as pending: #{invocations}"
        add_pending_specs(invocations)
        possible_matches.each(&:failing!)
      end
    end

    def add_pending_specs(invocations)
      invocations.each { |invocation| add_spec(invocation, PENDING) }
    end

    def print_banner_separated(headline, messages)
      banner = "================================================================================"
      <<~MSG
      #{headline}
      #{banner}
      #{messages.join(banner).strip}
      #{banner}
      MSG
    end
  end
end
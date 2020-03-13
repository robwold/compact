require_relative './argument_interceptor'
require_relative './invocation'
require 'set'
module Compact
  class Contract
    attr_reader :specs

    def initialize
      @collaborator_invocations = Set.new
      @test_double_invocations = Set.new
    end

    def prepare_double(block = Proc.new)
      double = block.call
      interceptor = ArgumentInterceptor.new(double)
      interceptor.register(self)
      interceptor
    end

    def verified?
      @test_double_invocations == @collaborator_invocations
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
      headline = "Attempts to verify the following method invocations failed:"
      messages = failing_invocations.map do |invocation|
        bad_results = unspecified_invocations.select{|p| p.matches_call(invocation) }
        invocation.describe.gsub("returns", "expected") +
            "\nMatching invocations returned the following values: #{bad_results.map(&:returns).inspect}"
      end
      print_banner_separated(headline, messages)
    end

    def verify(collaborator, block = Proc.new)
      interceptor = ArgumentInterceptor.new(collaborator)
      block.call(interceptor)
      interceptor.invocations.each{|inv| @collaborator_invocations.add(inv) }
    end

    def add_invocation(invocation)
      @test_double_invocations.add(invocation)
    end

    private

    def untested_invocations
      uncorroborated_invocations - failing_invocations
    end

    def pending_invocations
      unspecified_invocations.reject do |inv|
        failing_invocations.any? {|failure| inv.matches_call(failure)}
      end
    end

    def uncorroborated_invocations
      (@test_double_invocations - @collaborator_invocations).to_a
    end

    def unspecified_invocations
      (@collaborator_invocations - @test_double_invocations).to_a
    end

    def failing_invocations
      uncorroborated_invocations.select do |spec|
        unspecified_invocations.any?{|inv| inv.matches_call(spec)}
      end
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
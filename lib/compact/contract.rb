require_relative './spec'
require_relative './argument_interceptor'
module Compact
  class Contract
    attr_reader :specs

    def initialize(name)
      @name = name
      @specs = []
    end

    def add_spec(method:, args:, returns:)
      @specs.push Spec.new(method: method, args: args, returns: returns)
    end

    def unverified_specs
      @specs.reject(&:verified?)
    end

    def verified_specs
      @specs.select(&:verified?)
    end

    def verify(collaborator)
      interceptor = ArgumentInterceptor.new(collaborator)
      yield(interceptor)
      spec = spec_matching?(interceptor)
      spec.verify if spec
      !spec.nil?
    end

    private
    def spec_matching?(interceptor)
      @specs.find{|spec| matches?(spec, interceptor) }
    end

    def matches?(spec, interceptor)
      invocations = interceptor.invocations[spec.method]
      return false unless invocations
      invocations.any?{|invocation| invocation[:args] == spec.args && invocation[:returns] == spec.returns }
    end
  end
end
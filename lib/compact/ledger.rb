module Compact
  class Ledger

    def initialize
      @contracts = Hash.new(Contract.new)
    end

    def record_contract(name, test_double)
      contract = @contracts[name]
      contract.watch(test_double)
    end

    def verify_contract(name, test_double, block = Proc.new )
      contract = @contracts[name]
      contract.verify(test_double, block)
    end

    def verified_specs(name)
      contract = @contracts[name]
      contract.verified_invocations
    end
  end
end
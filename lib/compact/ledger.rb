module Compact
  class Ledger

    def initialize
      @contracts = {}
    end

    def record_contract(name, test_double)
      @contracts[name] ||= Contract.new
      contract = @contracts[name]
      contract.watch(test_double)
    end

    def verify_contract(name, test_double, block = Proc.new )
      contract = @contracts[name]
      contract.verify(test_double, block)
    end

    def summary
      unverified_contracts = []
      @contracts.each do |name, contract|
        unverified_contracts << contract unless contract.verified?
      end
      if unverified_contracts.empty?
        'All test double contracts are satisfied.'
      else
        <<~EOF
        The following contracts could not be verified:
        #{summarise_unverified_contracts}
        EOF
      end
    end

    private
    def summarise_unverified_contracts
      summary = ""
      @contracts.each do |name, contract|
        summary += "Role Name: #{name}\n#{contract.describe_unverified_specs}"
      end
      summary.strip
    end

    # def verified_specs(name)
    #   contract = @contracts[name]
    #   contract.verified_invocations
    # end
  end
end
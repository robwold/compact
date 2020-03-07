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

    def verify_contract(name, collaborator, block = Proc.new )
      @contracts[name] ||= Contract.new
      contract = @contracts[name]
      contract.verify(collaborator, block)
    end

    def summary
      unverified_contracts = []
      @contracts.each do |name, contract|
        unverified_contracts << contract unless contract.verified?
      end
      if unverified_contracts.empty?
        'All test double contracts are satisfied.'
      else
        msg = <<~EOF
        The following contracts could not be verified:
        #{summarise_untested_contracts}
        #{summarise_pending_contracts}
        #{summarise_failing_contracts}
        EOF
        msg.gsub(/\n+/, "\n")
      end
    end

    private
    def summarise_untested_contracts
      return nil unless @contracts.values.any?{|c| c.has_untested? }
      summary = ""
      @contracts.each do |name, contract|
        summary += "Role Name: #{name}\n#{contract.describe_untested_specs}" if contract.has_untested?
      end
      summary.strip
    end

    def summarise_pending_contracts
      return nil unless @contracts.values.any?{|c| c.has_pending? }
      summary = ""
      @contracts.each do |name, contract|
        summary += "Role Name: #{name}\n#{contract.describe_pending_specs}" if contract.has_pending?
      end
      summary.strip
    end

    def summarise_failing_contracts
      return nil unless @contracts.values.any?{|c| c.has_failing? }
      summary = ""
      @contracts.each do |name, contract|
        summary += "Role Name: #{name}\n#{contract.describe_failing_specs}" if contract.has_failing?
      end
      summary.strip
    end

  end
end
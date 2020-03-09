module Compact
  class Ledger

    def initialize
      @contracts = {}
    end

    def prepare_double(name, block = Proc.new)
      @contracts[name] ||= Contract.new
      contract = @contracts[name]
      contract.prepare_double(block)
    end

    # deprecate this?
    def record_contract(name, test_double, methods_to_watch = [])
      @contracts[name] ||= Contract.new
      contract = @contracts[name]
      contract.watch(test_double, methods_to_watch)
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

    # If the metaprogramming gets clunky to work with here git can help you out with
    # some explicit, repetitive definitions.
    [:untested, :pending, :failing].each do |category|
      method_name = "summarise_#{category}_contracts"
      test_for_presence = "has_#{category}?"
      describe_category_specs = "describe_#{category}_specs"
      define_method(method_name) do
        return nil unless @contracts.values.any?{|c| c.send(test_for_presence) }
        summary = ""
        @contracts.each do |name, contract|
          summary += "Role Name: #{name}\n#{contract.send(describe_category_specs)}" if contract.send(test_for_presence)
        end
        summary.strip
      end
    end

  end
end
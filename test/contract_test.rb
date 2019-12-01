require 'minitest/autorun'
require 'compact/contract'
require_relative './dumb_object'

class ContractTest < MiniTest::Test

  def new_contract
    @subject = Contract.new('dumb_object')
  end

  def contract_with_spec
    contract = new_contract
    contract.add_spec(method: :add,
                      args: [1,2],
                      returns: 3)
    contract
  end

  def test_creation
    assert_equal({}, new_contract.specs)
  end

  def test_adding_a_spec
    contract = contract_with_spec
    spec = contract.specs[:add]
    assert_equal Spec.new(method: :add,
                          args: [1,2],
                          returns: 3), spec
    assert_equal [spec], contract.unverified_specs
  end
end
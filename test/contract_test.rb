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
    assert_equal([], new_contract.specs)
  end

  def test_adding_a_spec
    contract = contract_with_spec
    spec = contract.specs.first
    assert_equal Spec.new(method: :add,
                          args: [1,2],
                          returns: 3), spec
    assert_equal [spec], contract.unverified_specs
    assert contract.verified_specs.empty?
  end

  def test_passing_contract_verification
    contract = contract_with_spec
    collaborator = DumbObject.new
    assert contract.verify(collaborator){|obj| obj.add(1,2)}
    assert contract.unverified_specs.empty?
    refute_nil contract.verified_specs.first
  end

  def test_failing_contract_verification
    contract = contract_with_spec
    bad_collaborator = Object.new
    def bad_collaborator.add(x,y)
      -1
    end
    refute contract.verify(bad_collaborator){|obj| obj.add(1,2)}
    assert contract.verified_specs.empty?
    refute_nil contract.unverified_specs.first
  end

  def test_invalid_contract_verification
    contract = contract_with_spec
    collaborator = DumbObject.new
    refute contract.verify(collaborator){|obj| obj.add(2,3)}
    assert contract.verified_specs.empty?
    refute_nil contract.unverified_specs.first
  end

end
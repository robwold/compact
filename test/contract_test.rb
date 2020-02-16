require_relative './test_helper'
require_relative './dumb_object'

class ContractTest < MiniTest::Test

  def new_contract
    @subject = Contract.new
  end

  def contract_with_spec
    contract = new_contract
    contract.add_spec(invocation: example_invocation)
    contract
  end

  def test_creation
    assert_equal([], new_contract.specs)
  end

  def example_invocation
    Invocation.new(method: :add,
                   args: [1,2],
                   returns: 3)
  end

  def test_adding_a_spec
    contract = contract_with_spec
    spec = contract.specs.first
    invocation = example_invocation
    assert_equal Spec.new(invocation: invocation), spec
    assert_equal [invocation], contract.unverified_invocations
    assert contract.verified_invocations.empty?
  end

  def test_passing_contract_verification
    contract = contract_with_spec
    collaborator = DumbObject.new
    assert_equal VERIFIED, contract.verify(collaborator){|obj| obj.add(1,2)}
    assert contract.verified?
    assert_equal contract.verified_invocations.first, example_invocation
  end

  def test_failing_contract_verification
    contract = contract_with_spec
    bad_collaborator = Object.new
    def bad_collaborator.add(x,y)
      -1
    end
    assert_equal FAILING, contract.verify(bad_collaborator){|obj| obj.add(1,2)}
    assert contract.verified_invocations.empty?
    refute_nil contract.unverified_invocations.first
  end

  def test_contract_verification_without_collaboration_test
    contract = contract_with_spec
    collaborator = DumbObject.new
    assert_equal PENDING, contract.verify(collaborator){|obj| obj.add(2,3)}
    assert contract.verified_invocations.empty?
    assert_equal contract.pending_invocations, [Invocation.new( method: :add, args: [2,3], returns: 5)]
  end

  def test_recording_interactions
    contract = new_contract
    stub = Object.new
    def stub.multiply(a,b)
      6
    end
    contract.watch(stub)
    stub.multiply(2,3)
    assert_equal [Invocation.new(method: :multiply, args: [2,3], returns: 6)],
                 contract.unverified_invocations
  end

  def test_describe_pending_specs
    contract = contract_with_spec
    expected = <<~MSG
      The following methods were invoked on test doubles without corresponding contract tests:
      ================================================================================
      method: add
      invoke with: [1, 2]
      returns: 3
      ================================================================================
    MSG
    assert_equal expected, contract.describe_unverified_specs
  end

end
require_relative './test_helper'
require_relative './dumb_object'
require 'mocha/minitest'

class ContractTest < MiniTest::Test

  def new_contract
    @subject = Contract.new
  end

  def contract_with_spec
    contract = new_contract
    contract.add_invocation(example_invocation)
    contract
  end

  def example_invocation
    Invocation.new(method: :add,
                   args: [1,2],
                   returns: 3)
  end

  def test_passing_contract_verification
    contract = contract_with_spec
    collaborator = DumbObject.new
    contract.verify(collaborator){|obj| obj.add(1,2)}
    assert contract.verified?
  end

  def test_contract_verification_out_of_order
    contract = new_contract
    collaborator = DumbObject.new
    contract.verify(collaborator){|obj| obj.add(1,2) }
    refute contract.verified?

    stub = contract.prepare_double{ TestHelpers::stubs_add_one_two }
    stub.add(1,2)
    assert contract.verified?
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
    assert_equal expected, contract.describe_untested_specs
  end

  def test_double_decoration
    contract = Contract.new
    stub = contract.prepare_double do
      TestHelpers.stubs_add_one_two
    end
    stub.add(1,2)

    collaborator = DumbObject.new
    contract.verify(collaborator){|obj| obj.add(1,2)}
    assert contract.verified?
  end

  def test_prepare_double_works_with_minitest_mocks
    contract = Contract.new
    mock = contract.prepare_double do
      mock = Minitest::Mock.new
      mock.expect(:add,3,[1,2]) # method returns the mock itself
    end
    assert_raises(MockExpectationError){ mock.verify }

    mock.add(1,2)
    collaborator = DumbObject.new
    contract.verify(collaborator){|obj| obj.add(1,2)}
    assert contract.verified?
  end

  def test_prepare_works_with_mocha_mocks
    contract = Contract.new
    mock = contract.prepare_double do
      mock = mock('adder')
      mock.expects(:add).with(1,2).returns(3)
      mock
    end
    # Don't think mocha mocks have an explicit verify method;
    # How to test this?
    # assert_raises(MockExpectationError){ mock.verify }

    mock.add(1,2)
    collaborator = DumbObject.new
    contract.verify(collaborator){|obj| obj.add(1,2)}
    assert contract.verified?
  end

  # Error must be raised on method exit here; how to test this?
  def test_prepare_is_transparent_to_mocha_mocks
    skip
    assert_raises(Exception) do
        contract = Contract.new
        mock = contract.prepare_double do
          mock = mock('adder')
          mock.expects(:add).with(1,2).returns(3)
          mock
        end
    end
  end

end
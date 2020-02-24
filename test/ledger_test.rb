require_relative './test_helper'
require_relative './dumb_object'

class LedgerTest < MiniTest::Test

  def test_spec_verification_in_order
    ledger = ledger_with_contract
    collaborator = DumbObject.new
    ledger.verify_contract('adder', collaborator){|collaborator| collaborator.add(1,2) }
    assert_equal 'All test double contracts are satisfied.', ledger.summary
  end

  def test_unverified_spec
    ledger = ledger_with_contract
    expected = <<~MSG
      The following contracts could not be verified:
      Role Name: adder
      The following methods were invoked on test doubles without corresponding contract tests:
      ================================================================================
      method: add
      invoke with: [1, 2]
      returns: 3
      ================================================================================
    MSG
    assert_equal expected, ledger.summary
  end

  def test_pending_spec
    ledger = Ledger.new
    collaborator = DumbObject.new
    ledger.verify_contract('adder', collaborator){|adder| adder.add(1,2) }
    expected = <<~MSG
      The following contracts could not be verified:
      Role Name: adder
      No test doubles mirror the following verified invocations:
      ================================================================================
      method: add
      invoke with: [1, 2]
      returns: 3
      ================================================================================
    MSG
    assert_equal expected, ledger.summary
  end

  def test_failing_spec
    skip
    ledger = Ledger.new

    bad_collaborator = Object.new
    def bad_collaborator.add(x,y)
      -1
    end
    ledger.verify_contract('adder', bad_collaborator){|adder| adder.add(1,2) }
    expected = <<~MSG
      The following contracts could not be verified:
      Role Name: adder
      Attempts to verify the following method invocations failed:
      ================================================================================
      method: add
      invoke with: [1, 2]
      expected: 3
      returned: -1
      ================================================================================
    MSG
    assert_equal expected, ledger.summary
  end

  private

  def ledger_with_contract
    ledger = Ledger.new
    stub = TestHelpers.stubs_add_one_two
    ledger.record_contract('adder', stub)
    # in real useage stub would be injected as a dependency, and this would be
    # invoked in a collaboration test
    stub.add(1, 2)
    ledger
  end
end
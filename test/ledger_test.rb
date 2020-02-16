require_relative './test_helper'
require_relative './dumb_object'

class LedgerTest < MiniTest::Test

  def get_adder_stub
    stub = Object.new
    def stub.add(x,y)
      3
    end
    stub
  end

  def test_spec_verification_in_order
    ledger = Ledger.new
    collaborator = DumbObject.new
    stub = get_adder_stub
    ledger.record_contract('adder', stub)
    # This would occur inside some method under test
    stub.add(1,2)
    ledger.verify_contract('adder', collaborator){|collaborator| collaborator.add(1,2)}
    assert_equal 'All test double contracts are satisfied.', ledger.summary
  end

  def test_unverified_spec
    ledger = Ledger.new
    stub = get_adder_stub
    ledger.record_contract('adder', stub)
    stub.add(1,2)
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
end
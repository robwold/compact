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
    ledger.record('adder',stub)
    # This would occur inside some method under test
    stub.add(1,2)
    ledger.verify('adder', collaborator){|collaborator| collaborator.add(1,2)}
    assert_equal [Invocation.new(method: :add,
                                 args: [1,2],
                                 returns: 3)], ledger.verified_specs('adder')
  end
end
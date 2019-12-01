require 'minitest/autorun'
require 'compact/contract'

class ContractTest < MiniTest::Test

  def test_creation
    subject = Contract.new('dumb_object')
    assert_equal({}, subject.specs)
  end
  
end
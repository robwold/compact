require 'minitest/autorun'
require 'compact/contract'

class ContractTest < MiniTest::Test

  def setup
    @subject = Contract.new('dumb_object')
  end

  def test_creation
    assert_equal({}, @subject.specs)
  end

  def test_adding_a_spec
    skip
    @subject.add_spec(method: :add,
                      args: [1,2],
                      returns: 3)

  end
end
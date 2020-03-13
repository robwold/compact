require 'minitest/autorun'
require_relative '../src/adder'
require 'compact'

class AdderTest < MiniTest::Test
  def test_addition_contract
    adder = Adder.new
    Compact.verify_contract('adder', adder){|adder| assert_equal 3, adder.add(1,2) }
  end
end
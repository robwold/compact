require 'minitest/autorun'
require_relative '../src/multiplier'
require 'compact'

class MultiplierTest < MiniTest::Unit::TestCase
  # NO multiplication collaboration test!
  def test_multiplication_contract
    multiplier = Multiplier.new
    Compact.verify_contract('multiplier', multiplier) do |multiplier|
      assert_equal 6, multiplier.multiply(2,3)
    end
  end
end
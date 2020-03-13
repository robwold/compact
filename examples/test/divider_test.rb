require 'minitest/autorun'
require_relative '../src/divider'
require 'compact'

class DividerTest < MiniTest::Test
  # Mismatched assertion
  def test_division_contract
    divider = Divider.new
    Compact.verify_contract('divider', divider){|divider| assert_equal 2, divider.divide(5,2) }
  end
end
require 'minitest/autorun'
require_relative '../src/calculator'

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "compact"
include Compact
class CalculatorTest < MiniTest::Test

  def test_addition
    adder, subtracter, multiplier, divider = [MiniTest::Mock.new, MiniTest::Mock.new,MiniTest::Mock.new,MiniTest::Mock.new]
    adder.expect(:add,3,[1,2])
    # TODO make support named methods
    Compact.record_contract('adder', adder)
    subject = Calculator.new(adder, subtracter, multiplier, divider)
    subject.add(1,2)
  end
end
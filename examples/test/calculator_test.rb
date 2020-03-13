require 'minitest/autorun'
require_relative '../src/calculator'
require_relative '../src/adder'
require_relative '../src/multiplier'
require_relative '../src/divider'

# Used in development if you don't have the gem installed:
# $LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "compact"

#
# The calculator class delegates its difficult arithmetic
# work to four service classes.
#
# Addition provides a happy example of contract validation.
# Subtraction has a collaboration test without a contract test.
# Multiplication is a collaborator in search of a collaboration.
# Division tells the unhappy story of a soul who's confused about
# whether they want integer or floating point division.
class CalculatorTest < MiniTest::Test

  def test_addition_collaboration
    adder = Compact.prepare_double('adder') do
      adder = Minitest::Mock.new
      adder.expect(:add,3,[1,2])
    end

    subject = Calculator.new(adder, nil, nil, nil)
    subject.add(1,2)
  end

  # NO subtraction contract test!
  def test_subtraction_collaboration
    subtracter = Compact.prepare_double('subtracter') do
      subtracter = Minitest::Mock.new
      subtracter.expect(:subtract,5,[7,2])
    end

    subject = Calculator.new(nil, subtracter, nil, nil)
    subject.subtract(7,2)
  end



  def test_division_collaboration
    divider = Compact.prepare_double('divider') do
      mock = Minitest::Mock.new
      mock.expect(:divide,2.5,[5,2])
    end

    subject = Calculator.new(nil, nil, nil, divider)
    subject.divide(5,2)
  end



end
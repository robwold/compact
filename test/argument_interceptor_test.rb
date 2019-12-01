require 'minitest/autorun'
require 'compact/argument_interceptor.rb'


class ArgumentInterceptorTest < MiniTest::Test

  class DumbObject
    def add(first_arg, second_arg)
      first_arg + second_arg
    end
  end

  def setup
    dumb_object = DumbObject.new
    @subject = ArgumentInterceptor.new(dumb_object)
  end

  def test_it_decorates_the_object
    expected = 3
    assert_equal expected, @subject.add(1, 2)
  end

  def test_registers_args
    @subject.add(1, 2)
    @subject.add(3, 4)
    expected = {add: [[1, 2], [3, 4]]}
    assert_equal expected, @subject.invocations
  end
end
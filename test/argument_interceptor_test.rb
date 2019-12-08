require_relative './test_helper'
require_relative './dumb_object'

class ArgumentInterceptorTest < MiniTest::Test

  def setup
    dumb_object = DumbObject.new
    @subject = ArgumentInterceptor.new(dumb_object)
  end

  def test_it_decorates_the_object
    expected = 3
    assert_equal expected, @subject.add(1, 2)
  end

  def test_registers_args_and_results
    @subject.add(1, 2)
    @subject.add(3, 4)
    expected = [ Invocation.new(method: :add, args: [1, 2], returns: 3),
                 Invocation.new(method: :add, args:[3, 4], returns: 7)]
    assert_equal expected, @subject.invocations
  end
end
require_relative './test_helper'

class SpecTest < MiniTest::Test

  def test_creation
    invocation = Invocation.new(args: [1],
                                method: :foo,
                                returns: [2])
    subject = Spec.new(invocation: invocation)
    refute subject.verified?
    # assert_equal :foo, subject.method
    # assert_equal [1], subject.args
    # assert_equal [2], subject.returns
  end
end
require_relative './test_helper'

class SpecTest < MiniTest::Test

  def test_creation
    subject = Spec.new(args: [1],
                       method: :foo,
                       returns: [2])
    refute subject.verified?
    assert_equal :foo, subject.method
    assert_equal [1], subject.args
    assert_equal [2], subject.returns
  end
end
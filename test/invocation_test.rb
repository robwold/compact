require_relative './test_helper'


class InvocationTest < MiniTest::Test

  def invocation
    Invocation.new(method: :add,
                   args: [1,2],
                   returns: 3)
  end

  def test_description
    subject = invocation
    expected = <<~DESCRIPTION
      method: add
      invoke with: [1, 2]
      returns: 3
    DESCRIPTION
    assert_equal expected, subject.describe
  end

  def test_is_a_value_object
    i1 = invocation
    i2 = invocation
    assert i1 == i2
    assert i1.eql? i2
    assert i1.hash == i2.hash
  end
end
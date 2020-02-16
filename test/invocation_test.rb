require_relative './test_helper'


class InvocationTest < MiniTest::Test

  def test_description
    subject = Invocation.new(method: :add,
                   args: [1,2],
                   returns: 3)
    expected = <<~DESCRIPTION
      method: add
      invoke with: [1, 2]
      returns: 3
    DESCRIPTION
    assert_equal expected, subject.describe
  end
end
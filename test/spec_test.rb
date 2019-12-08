require_relative './test_helper'

class SpecTest < MiniTest::Test

  def test_creation
    invocation = Invocation.new(args: [1],
                                method: :foo,
                                returns: [2])
    subject = Spec.new(invocation: invocation)
    refute subject.verified?
    refute subject.pending?
  end
end
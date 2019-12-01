require 'minitest/autorun'
require 'compact/spec'

class SpecTest < MiniTest::Test

  def test_creation
    subject = Spec.new(method: :foo,
             args: [1],
             returns: [1])
    refute subject.verified?
  end
end
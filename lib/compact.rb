require "compact/version"
require 'compact/contract'
require 'compact/ledger'
require 'compact/verification_codes'

#
# This TOP-level module defines the entire public API of the gem.
#
module Compact
  @@ledger = Ledger.new

  # To record the interactions of your test_double,
  # prepare inside a block passed to this method.
  # Give the role played by the mock a name so we can
  # cross-reference it with tests against the real
  # implementation.
  #
  #   my_watched_mock = Compact.prepare_double('role_name') do
  #     mock = MyMock.new
  #     mock.expect(:method_name, return_args, when_called_with)
  #   end
  #
  # The returned mock is decorated with an +ArgumentInterceptor+ that records:
  # - methods sent to it
  # - the arguments with which they were called
  # - and the return values
  # and stores these in an instance of the +Ledger+ class for comparison
  # with the corresponding contract tests in +verify_contract+.
  def self.prepare_double(name, block = Proc.new)
    @@ledger.prepare_double(name, block)
  end

  # Calling this method checks that the +collaborator+ param is
  # an object capable of fulfilling the role defined by +name+
  # (for which see +prepare_double+).
  #
  # Example usage:
  #
  # Compact.verify_contract('role_name', myObject) do
  #    expected = return_value
  #    actual =  myObject.method_name(*args_specified_by_test_double)
  #    assert_equal expected, actual
  # end
  #
  def self.verify_contract(name, collaborator, block = Proc.new )
    @@ledger.verify_contract(name, collaborator, block)
  end

  # Unlikely to be used by end users of this gem.
  # Used to write test reporters that give us the low-down at the end of our suite.
  def self.summary
    @@ledger.summary
  end

end

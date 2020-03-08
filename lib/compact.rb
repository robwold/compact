require "compact/version"
require 'compact/contract'
require 'compact/ledger'
require 'compact/verification_codes'

module Compact
  class LedgerWrapper
    @ledger = Ledger.new

    def self.record_contract(name, test_double)
      @ledger.record_contract(name, test_double)
    end

    def self.verify_contract(name, collaborator, block = Proc.new )
      @ledger.verify_contract(name, collaborator, block)
    end

    def self.summary
      @ledger.summary
    end
  end

  def self.record_contract(name, test_double)
    LedgerWrapper.record_contract(name, test_double)
  end

  def self.verify_contract(name, collaborator, block = Proc.new )
    LedgerWrapper.verify_contract(name, collaborator, block)
  end

  def self.summary
    LedgerWrapper.summary
  end



end

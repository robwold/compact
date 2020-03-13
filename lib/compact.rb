require "compact/version"
require 'compact/contract'
require 'compact/ledger'
require 'compact/verification_codes'

module Compact
  class LedgerWrapper
    @ledger = Ledger.new

    def self.prepare_double(name, block = Proc.new)
      @ledger.prepare_double(name, block)
    end

    def self.verify_contract(name, collaborator, block = Proc.new )
      @ledger.verify_contract(name, collaborator, block)
    end

    def self.summary
      @ledger.summary
    end
  end

  def self.prepare_double(name, block = Proc.new)
    LedgerWrapper.prepare_double(name, block)
  end

  def self.verify_contract(name, collaborator, block = Proc.new )
    LedgerWrapper.verify_contract(name, collaborator, block)
  end

  def self.summary
    LedgerWrapper.summary
  end

end

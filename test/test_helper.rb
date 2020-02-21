require 'simplecov'
SimpleCov.start
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "compact"
include Compact

require "minitest/autorun"


module Compact::TestHelpers
  def self.stubs_add_one_two
    stub = Object.new
    def stub.add(x,y)
      3
    end
    stub
  end
end
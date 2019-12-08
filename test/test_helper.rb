require 'simplecov'
SimpleCov.start
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "compact"
include Compact

require "minitest/autorun"

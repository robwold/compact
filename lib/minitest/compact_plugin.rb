require_relative './compact_reporter'
module Minitest
  def self.plugin_compact_options(opts, options) ; end


  def self.plugin_compact_init(options)
    self.reporter << CompactReporter.new
  end
end

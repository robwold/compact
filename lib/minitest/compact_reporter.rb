require_relative '../compact'
module Minitest
  class CompactReporter < AbstractReporter

    def record(result); end

    def report
      puts Compact.summary
    end
  end
end

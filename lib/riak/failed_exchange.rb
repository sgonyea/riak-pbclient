require 'riak'

module Riakpb
  # Exception raised when the expected response code from Riakpb
  # fails to match the actual response code.
  class FailedExchange < StandardError
    include Util::Translation

    attr_reader :expected
    attr_reader :actual
    attr_reader :output
    attr_reader :stub

    def initialize(expected, actual, output, stub)
      @expected, @actual, @output, @stub = expected, actual, output, stub
      super t("failed_rx", :failure => 
                t(@stub, :expected => @expected, :actual => @actual, :output => @output.inspect)
            )
    end
  end
end

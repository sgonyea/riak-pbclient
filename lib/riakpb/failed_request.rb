require 'riakpb'

module Riakpb
  # Exception raised when the expected response code from Riakpb
  # fails to match the actual response code.
  class FailedRequest < StandardError
    include Riakpb::Util::Translation

    attr_reader :expected
    attr_reader :actual
    attr_reader :output
    attr_reader :message

    def initialize(expected=nil, actual=nil, output=nil, message=nil)
      @expected = expected
      @actual   = actual
      @output   = output
      @message  = message || "failed_request"
      super t(@message, :expected => @expected, :actual => @actual, :output => @output.inspect)
    end
  end
end

require 'riak'

module Riakpb
  # Exception raised when the expected response code from Riakpb
  # fails to match the actual response code.
  class SiblingError < StandardError
    include Riakpb::Util::Translation

    attr_reader :key

    def initialize(key)
      @key = key
      super t("unresolved_siblings", :key => @key)
    end
  end
end

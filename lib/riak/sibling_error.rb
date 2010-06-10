require 'riak'

module Riak
  # Exception raised when the expected response code from Riak
  # fails to match the actual response code.
  class SiblingError < StandardError
    include Riak::Util::Translation

    attr_reader :key

    def initialize(key)
      @key = key
      super t("unresolved_siblings", :key => @key)
    end
  end
end

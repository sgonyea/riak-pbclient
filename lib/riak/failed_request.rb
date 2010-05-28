# Copyright 2010 Sean Cribbs, Sonian Inc., and Basho Technologies, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
require 'riak'

module Riak
  # Exception raised when the expected response code from Riak
  # fails to match the actual response code.
  class FailedRequest < StandardError
    include Util::Translation
    # @return [Fixnum] the expected response code
    attr_reader :expected
    # @return [Fixnum] the received response code
    attr_reader :code
    # @return [String] the response body, if present
    attr_reader :body

    def initialize(expected_code, response_code, body)
      @exp_mc, @resp_mc, @msg = expected_code, response_code, body
      super t("bug_found", :exp_mc => @expected, :resp_mc => @resp_mc, :msg => @msg.inspect)
    end
  end
end

# Copyright 2010 Sean Cribbs, Sonian Inc., and Basho Technologies, Inc.
#        Copyright 2010 Scott Gonyea, Inherently Lame, Inc.
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
#  module Client
    # A client connection to Riak.
    class Client
      include Util::Translation
      include Util::MessageCode

      autoload :Rpc,      'riak/client/rpc'

      # Regexp for validating hostnames
      HOST_REGEX = /^([[:alnum:]]+\.)+[[:alnum:]]+$/

      # Creates a client connection to Riak's Protobuf Listener
      # @param [String] options configuration options for the client
      # @param [String] host ('127.0.0.1') The host or IP address for the Riak endpoint
      # @param [Fixnum] port (8097) The port of the Riak protobuf listener endpoint
      def initialize(host="127.0.0.1", port=8087)
      
        self.host         = host
        self.port         = port

        list_buckets
      end
      attr_reader :host, :port, :buckets

      # Set the hostname of the Riak endpoint. Must be an IPv4, IPv6, or valid hostname
      # @param [String] value The host or IP address for the Riak endpoint
      # @raise [ArgumentError] if an invalid hostname is given
      # @return [String] the assigned hostname
      def host=(value)
        raise ArgumentError, t("hostname_invalid") unless value.is_a?(String) && value =~ HOST_REGEX
        @host = value
      end

      # Set the port number of the Riak endpoint. This must be an integer between 0 and 65535.
      # @param [Fixnum] value The port number of the Riak endpoint
      # @raise [ArgumentError] if an invalid port number is given
      # @return [Fixnum] the assigned port number
      def port=(value)
        raise ArgumentError, t("port_invalid") unless (0..65535).include?(value)
        @port = value
      end
    
      def rpc
        @rpc ||= Rpc.new(self)
      end

      # Retrieves a bucket from Riak.
      # @param [String] bucket the bucket to retrieve
      # @param [Hash] options options for retrieving the bucket
      # @option options [Boolean] :keys (true) whether to retrieve the bucket keys
      # @option options [Boolean] :props (true) whether to retreive the bucket properties
      # @return [Bucket] the requested bucket
      def bucket(name, options={})
        options.assert_valid_keys(:keys, :props)
        response = http.get(200, prefix, escape(name), options, {})
        Bucket.new(self, name).load(response)
      end
      alias :[] :bucket
      
      # @return [String] A representation suitable for IRB and debugging output.
#      def inspect
#        "#<Client >"
#      end
  
      def ping?
        rpc.request PING_REQUEST
        
        return rpc.resp_message_code == PING_RESPONSE
      end
      
      def list_buckets
        
      end

      private

    end # class Client
#  end # module Client
end # module Riak

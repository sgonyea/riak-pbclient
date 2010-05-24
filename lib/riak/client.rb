# Copyright 2010, Scott Gonyea
#
#                     Shamelessly lifted from:
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
      @_buckets         = []
      @_bucket_keys     = Hash.new{|k,v| k[v] = []}
    end
    attr_reader :host, :port, :buckets, :_buckets, :_bucket_keys

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
    def get_bucket(bucket, options={})
      options.assert_valid_keys(:keys, :props)
      response = http.get(200, prefix, escape(bucket), options, {})
      Bucket.new(self, bucket).load(response)
    end
    alias :[] :get_bucket
    
    # Retrieves a key, stored in the given bucket, from Riak.
    # @param [String] bucket the bucket from which to retrieve the key
    # @param [String] key the name of the key to be received
    # @param [Hash] options options for retrieving the key
    # @option options [Boolean] :props (true) whether to retreive the bucket properties
    # @return [Key] the requested key
    def get_key(bucket, key, options={})
      options.assert_valid_keys(:props)
      response = http.get(200, prefix, escape(name), options, {})
      Key.new(self, name).load(response)
    end
    
    # @return [String] A representation suitable for IRB and debugging output.
#      def inspect
#        "#<Client >"
#      end

    # Tests connectivity with the Riak host.
    # @return [Boolean] Successful returned as 'true', failed connection returned as 'false'
    def ping?
      rpc.request PING_REQUEST
      
      return rpc.resp_message_code == PING_RESPONSE
    end
    
#    def get
#      
#    end
    
    # Lists the buckets found in the Riak database
    # @raise [ReturnRespError] if the message response does not correlate with the message requested
    # @return [Array] list of buckets (String)
    def list_buckets
      rpc.request LIST_BUCKETS_REQUEST, nil, RpbListBucketsResp
      
      raise ReturnRespError,
        t("response_incorrect") if rpc.resp_message_code != LIST_BUCKETS_RESPONSE
      
      # iterate through each of the Strings in the Bucket list, returning an array of String(s)
      @_buckets = rpc.response.buckets.each{|b| b}
    end
    
    # Lists the keys within their respective buckets, that are found in the Riak database
    # @raise [ReturnRespError] if the message response does not correlate with the message requested
    # @return [Hash] Mapping of the buckets (String) to their keys (Array of Strings)
    def list_keys
      @_bucket_keys.clear
      
      @_buckets.each do |bucket|
        list_keys_request   = RpbListKeysReq.new(:bucket => bucket)
        
        rpc.request LIST_KEYS_REQUEST, list_keys_request, RpbListKeysResp
        
        raise ReturnRespError,
          t("response_incorrect") if rpc.resp_message_code != LIST_KEYS_RESPONSE
        
        @_bucket_keys[bucket] = rpc.response.keys.each{|b| b}
      end
      
      @_bucket_keys
    end

    private

  end # class Client
end # module Riak

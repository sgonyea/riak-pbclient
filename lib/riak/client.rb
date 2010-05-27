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

    autoload :Rpc, 'riak/client/rpc'

    # Regexp for validating hostnames
    #   http://rubular.com/r/N2HOgxFkN3
    HOST_REGEX = /^([[:alnum:]]+(-*[[:alnum:]]+)*(\.{0,1}(([[:alnum:]]-*)*[[:alnum:]]+)+)*)+$/

    # Creates a client connection to Riak's Protobuf Listener
    # @param [String] options configuration options for the client
    # @param [String] host ('127.0.0.1') The host or IP address for the Riak endpoint
    # @param [Fixnum] port (8087) The port of the Riak protobuf listener endpoint
    def initialize(options={})
      self.host         = options[:host]  || "127.0.0.1"
      self.port         = options[:port]  || 8087
      @_buckets         = []
    end
    attr_reader :host, :port, :buckets, :_buckets

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

    # Establish a connection to the riak node, and store the Rpc instance
    # @return [Riak::Client::Rpc] the Rpc instance that handles connections to the riak node
    def rpc
      @rpc ||= Rpc.new(self)
    end

    # Tests connectivity with the Riak host.
    # @return [Boolean] Successful returned as 'true', failed connection returned as 'false'
    def ping?
      rpc.request Util::MessageCode::PING_REQUEST
      
      return rpc.resp_message_code == PING_RESPONSE
    end

    # I need bucket!  Bring me a bucket! (Retrieves a bucket from Riak.)
    # @param [String] bucket the bucket to retrieve
    # @param [Hash] options options for retrieving the bucket
    # @option options [Boolean] :keys (true) whether to retrieve the bucket keys
    # @return [Bucket] the requested bucket
    def bring_me_bucket(bucket, options={})
#      options.assert_valid_keys(:keys, :props)
#      response = http.get(200, prefix, escape(bucket), options, {})
      request   = Riak::RpbGetBucketReq.new(:bucket => bucket)
      response  = rpc.request(
                    Util::MessageCode::GET_BUCKET_REQUEST,
                    request,
                    Riak::RpbGetBucketResp
                  )
      Bucket.new(self, bucket).load(response)
    end
    alias :[]     :bring_me_bucket
    alias :bucket :bring_me_bucket
    
    # Retrieves a key, using RpbGetReq, from within a given bucket, from Riak.
    # @param [String] bucket the bucket from which to retrieve the key
    # @param [String] key the name of the key to be received
    # @param [Fixnum] quorum read quorum- num of replicas need to agree when retrieving the object
    # @return [RpbGetResp] the response in which the given Key is stored
    def get_request(bucket, key, quorum=nil)
      request   = Riak::RpbGetReq.new({:bucket => bucket, :key => key})
      request.r = quorum if quorum.is_a?(Fixnum)
      
      response  = rpc.request(
                    Util::MessageCode::GET_REQUEST,
                    request,
                    Riak::RpbGetResp
                  )
      
      return(response)
    end
    alias :req :get_request
    alias :get :get_request
    
    # @return [String] A representation suitable for IRB and debugging output.
#      def inspect
#        "#<Client >"
#      end
    
    # Lists the buckets found in the Riak database
    # @raise [ReturnRespError] if the message response does not correlate with the message requested
    # @return [Array] list of buckets (String)
    def buckets
      rpc.request Util::MessageCode::LIST_BUCKETS_REQUEST, nil, RpbListBucketsResp
      
      raise ReturnRespError,
        t("response_incorrect") if rpc.resp_message_code != LIST_BUCKETS_RESPONSE
      
      # iterate through each of the Strings in the Bucket list, returning an array of String(s)
      @_buckets = rpc.response.buckets.each{|b| b}
    end
    
    # Lists the keys within their respective buckets, that are found in the Riak database
    # @param [String] bucket the bucket from which to retrieve the list of keys
    # @raise [ReturnRespError] if the message response does not correlate with the message requested
    # @return [Hash] Mapping of the buckets (String) to their keys (Array of Strings)
    def keys_in(bucket)
      
      list_keys_request = RpbListKeysReq.new(:bucket => bucket)
      
      rpc.request Util::MessageCode::LIST_KEYS_REQUEST,
                  list_keys_request,
                  Riak::RpbListKeysResp
      
      raise ReturnRespError,
        t("response_incorrect") if rpc.resp_message_code != Util::MessageCode::LIST_KEYS_RESPONSE
      
      return(rpc.response.keys.each{|k| k})
    end
    
    
    def rm_bucket(bucket, rw=nil)
      
    end
    
    def del_request(bucket, key, rw=nil)
      
    end
    
    
    
    private

  end # class Client
end # module Riak


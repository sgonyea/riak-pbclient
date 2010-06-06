# Copyright 2010, Scott Gonyea
#
#                     Shamelessly adapted from:
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
  # Represents and encapsulates operations on a Riak bucket.  You may retrieve a bucket
  # using {Client#bucket}, or create it manually and retrieve its meta-information later.
  class Bucket
    include Util::Translation
    include Util::MessageCode

    # @return [Riak::Client] the associated client
    attr_reader :client

    # @return [String] the bucket name
    attr_reader :name

    # @return [Fixnum] the number of replicas for objects in this bucket
    attr_reader :n_val

    # @return [TrueClass/FalseClass] whether or not a key's siblings are to be retrieved
    attr_reader :allow_mult

    attr_reader :key_cache

    # Create a Riak bucket manually.
    # @param [Client] client the {Riak::Client} for this bucket
    # @param [String] name the name of the bucket
    def initialize(client, name, options={})
      options.assert_valid_keys(:n_val, :allow_mult)
      raise ArgumentError, t("client_type", :client => client.inspect)  unless client.is_a?(Client)
      raise ArgumentError, t("string_type", :string => name.inspect)    unless name.is_a?(String)

      @client     = client
      @name       = name
      @n_val      = options[:n_val]       || nil
      @allow_mult = options[:allow_mult]  || nil
      @key_cache  = Hash.new{|k,v| k[v] = Riak::Key.new(self, v)}
    end

    # Load information for the bucket from a response given by the {Riak::Client::HTTPBackend}.
    # Used mostly internally - use {Riak::Client#bucket} to get a {Bucket} instance.
    # @param [RpbHash] response a response from {Riak::Client::HTTPBackend}
    # @return [Bucket] self
    # @see Client#bucket
    def load(response)
      raise ArgumentError, t("response_type") unless response.is_a?(Riak::RpbGetBucketResp)

      self.n_val      = response.props.n_val
      self.allow_mult = response.props.allow_mult

      return(self)
    end

    # Accesses or retrieves a list of keys in this bucket.  Needs to have expiration / cacheing, though not now.
    # @return [Array<String>] Keys in this bucket
    def keys
      @keys ||= @client.keys_in @name
    end

    # Accesses or retrieves a list of keys in this bucket.  Needs to have expiration / cacheing, though not now.
    # @return [Array<String>] Keys in this bucket
    def keys!
      @keys = @client.keys_in @name
    end

    # Retrieve an object from within the bucket.
    # @param [String] key the key of the object to retrieve
    # @param [Fixnum] r - the read quorum for the request - how many nodes should concur on the read
    # @return [Riak::Key] the object
    def key(key, options={})
      raise ArgumentError, t("fixnum_invalid", :num => options[:r]) unless options[:r].is_a?(NilClass) or options[:r].is_a?(Fixnum)
      raise ArgumentError, t("string_invalid", :string => key)      unless key.is_a?(String)

      if options[:safely] == true
        return(@key_cache[key]) unless @key_cache[key].empty?
      end

      response = @client.get_request @name, key, options[:r]

      @key_cache[key].load(response)
    end
    alias :[] :key

    # Retrieve an object from within the bucket.  Will raise an error message if key does not exist.
    # @param [String] key the key of the object to retrieve
    # @param [Fixnum] quorum - the read quorum for the request - how many nodes should concur on the read
    # @return [Riak::Key] the object
    def key!(key, r=nil)
      raise ArgumentError, t("string_invalid", :string  => key) unless key.is_a?(String)
      raise ArgumentError, t("fixnum_invalid", :num     => r)   unless r.is_a?(Fixnum)

      response = @client.get_request @name, key, r

      Riak::Key.new(self, key).load!(response)
    end

    # Retrieves a Key from the given Bucket. Originally written for link retrieval.
    # @param [String] bucket the name of the bucket, in which the Key is contained
    # @param [String] key the name of the key to retrieve
    # @option options [Fixnum] :quorum read quorum- num of replicas need to agree when retrieving the object
    # @return [Riak::Key] the object
    def get_linked(bucket, key, options=nil)
      @client[bucket].key(key, options)
    end

    # Retrieves a Key from the given Bucket. Originally written for link retrieval.
    # Inserts a key in this bucket's namespace, into riak.
    # @option options [Fixnum] :w (write quorum) how many replicas to write to before returning a successful response.
    # @option options [Fixnum :dw how many replicas to commit to durable storage before returning a successful response.
    # @option options [Boolean] :return_body whether to return the contents of the stored object.
    # @return [RpbPutResp] the response confirming Key storage and (optionally) the Key's updated/new data.
    def store(options)
      options[:bucket] = @name
      @client.put_request(options)
    end

    # Deletes a key from the bucket
    # @param [String] key the key to delete
    # @param [Hash] options quorum options
    # @option options [Fixnum] :rw - the read/write quorum for the delete
    def delete(key, rw=nil)
      key = key.name if key.is_a?(Riak::Key)

      @client.del_request(@name, key, rw)
    end

    # Wipes out all keys stored in the bucket, as of execution
    # @param [String] key the key to delete
    # @param [Hash] options quorum options
    # @option options [Fixnum] :rw - the read/write quorum for the delete
    def destroy!(rw=nil)
      keys!
      
      @keys.each do |key|
        @client.del_request(@name, key, rw)
      end
#      super.destroy
    end

    # @return [true, false] whether the bucket allows divergent siblings
    def allow_mult
      @allow_mult
    end

    # Set the allow_mult property.  *NOTE* This will result in a PUT request to Riak.
    # @param [true, false] value whether the bucket should allow siblings
    def allow_mult=(value)
      return(@allow_mult = value) if value.is_a?(TrueClass) or value.is_a?(FalseClass)

      raise ArgumentError, t("boolean_type")
    end

    # @return [Fixnum] the N value, or number of replicas for this bucket
    def n_val
      @n_val
    end

    # Set the N value (number of replicas).
    # Saving this value after the bucket has objects stored in it may have unpredictable results.
    # @param [Fixnum] value the number of replicas the bucket should keep of each object
    def n_val=(value)
      raise ArgumentError, t("fixnum_type", :value => value) unless value.is_a?(Fixnum)

      @n_val = value
    end

    # @return [String] a representation suitable for IRB and debugging output
    def inspect
      "#<Riak::Bucket name=#{@name}, props={n_val=>#{@n_val}, allow_mult=#{@allow_mult}}>"
    end

    # @return [String] a representation suitable for IRB and debugging output, including keys within this bucket
    def inspect!
      "#<Riak::Bucket name=#{@name}, props={n_val=>#{@n_val}, allow_mult=#{@allow_mult}}, keys=#{keys.inspect}>"
    end

  end
end

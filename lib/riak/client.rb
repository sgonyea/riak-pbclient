require 'riak'

module Riak
  # A client connection to Riak.
  class Client
    include Util::Translation
    include Util::MessageCode

    autoload :Rpc, 'riak/client/rpc'

    # When using integer client IDs, the exclusive upper-bound of valid values.
    MAX_CLIENT_ID = 4294967296

    # Regexp for validating hostnames
    #   http://rubular.com/r/N2HOgxFkN3
    HOST_REGEX = /^([[:alnum:]]+(-*[[:alnum:]]+)*(\.{0,1}(([[:alnum:]]-*)*[[:alnum:]]+)+)*)+$/

    attr_reader :host
    attr_reader :port
    attr_reader :buckets
    attr_reader :bucket_cache
    attr_reader :node
    attr_reader :server_version
    attr_reader :client_id
    attr_reader :options
    
    # Creates a client connection to Riak's Protobuf Listener
    # @options [Hash] options configuration options for the client
    def initialize(options={})
      self.host         = options[:host]      ||      "127.0.0.1"
      self.port         = options[:port]      ||      8087
      self.client_id    = options[:client_id] unless  options[:client_id].blank?
    
      read_quorum       = options[:r]         || options[:read_quorum]
      write_quorum      = options[:w]         || options[:write_quorum]
      replica_commit    = options[:dw]        || options[:replica_commit]
      return_body       = options[:rb]        || options[:return_body]    || true
    
      @options                = options.slice!(:host, :port, :client_id, :r, :read_quorum, :w, :write_quorum, :dw, :replica_commit, :rb, :return_body)
      @options[:r]            = read_quorum     unless read_quorum.blank?
      @options[:w]            = write_quorum    unless write_quorum.blank?
      @options[:dw]           = replica_commit  unless replica_commit.blank?
      @options[:return_body]  = return_body     unless return_body.blank?
    
      @buckets          = []
      @bucket_cache     = Hash.new{|k,v| k[v] = Riak::Bucket.new(self, v, @options)}
    end
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

    # Set the client ID for this client. Must be a string or Fixnum value 0 =< value < MAX_CLIENT_ID.
    # @param [String, Fixnum] value The internal client ID used by Riak to route responses
    # @raise [ArgumentError] when an invalid client ID is given
    # @return [String] the assigned client ID
    def client_id=(value)
      @client_id = case value
                   when 0...MAX_CLIENT_ID
                     b64encode(value)
                   when String
                     value
                   else
                     raise ArgumentError, t("invalid_client_id", :max_id => MAX_CLIENT_ID)
                   end
    end

    # Establish a connection to the riak node, and store the Rpc instance
    # @return [Riak::Client::Rpc] the Rpc instance that handles connections to the riak node
    def rpc(options={})
      options[:client_id] ||= @client_id if @client_id
      @rpc                ||= Rpc.new(self)
    end

    # Tests connectivity with the Riak host.
    # @return [Boolean] Successful returned as 'true', failed connection returned as 'false'
    def ping?
      rpc.request Util::MessageCode::PING_REQUEST

      return rpc.status
    end

    # Retrieves basic information from the riak node.
    # @return [Hash] Returns the name of the node and its software release number
    def info
      response        = rpc.request Riak::Util::MessageCode::GET_SERVER_INFO_REQUEST

      @node           = response.node
      @server_version = response.server_version

      {:node => @node, :server_version => @server_version}
    end

    # I need bucket!  Bring me bucket! (Retrieves a bucket from Riak.  Eating disorder not included.)
    # @param [String] bucket the bucket to retrieve
    # @return [Bucket] the requested bucket
    def bucket(bucket)
      return(@bucket_cache[bucket]) if @bucket_cache.has_key?(bucket)
      self.bucket!(bucket)
    end
    alias :[]               :bucket
    alias :bring_me_bucket  :bucket

    # I need bucket!  Bring me bucket! (Retrieves a bucket from Riak, even if it's already been retrieved.)
    # @param [String] bucket the bucket to retrieve
    # @return [Bucket] the requested bucket
    def bucket!(bucket)
      request       = Riak::RpbGetBucketReq.new(:bucket => bucket)
      response      = rpc.request(
                        Util::MessageCode::GET_BUCKET_REQUEST,
                        request
                      )
      @bucket_cache[bucket].load(response)
    end
    alias :bring_me_bucket! :bucket!

    # Set the properties for a given bucket, and then reload it.
    # @param [String] bucket the bucket name in which props will be set
    # @param [RpbBucketProps, Hash] props the properties to be set within the given bucket
    # @return [TrueClass, FalseClass] whether or not the operation was successful
    def set_bucket(bucket, props)
      props = Riak::RpbBucketProps.new(props) if props.is_a?(Hash)

      raise TypeError.new t('invalid_props') unless props.is_a?(Riak::RpbBucketProps)

      begin
        request       = Riak::RpbSetBucketReq.new(:bucket => bucket, :props => props)
        response      = rpc.request(
                          Util::MessageCode::SET_BUCKET_REQUEST,
                          request
                        )
        self.bucket!(bucket)

        return(true)
      rescue FailedRequest
        return(false)
      end
    end

    # Retrieves a key, using RpbGetReq, from within a given bucket, from Riak.
    # @param [String] bucket the bucket from which to retrieve the key
    # @param [String] key the name of the key to be received
    # @param [Fixnum] quorum read quorum- num of replicas need to agree when retrieving the object
    # @return [RpbGetResp] the response in which the given Key is stored
    def get_request(bucket, key, quorum=nil)
      request   = Riak::RpbGetReq.new({:bucket => bucket, :key => key})

      quorum  ||= @read_quorum
      unless quorum.blank?
        quorum    = quorum.to_i
        request.r = quorum
      end


      response  = rpc.request(
                    Util::MessageCode::GET_REQUEST,
                    request
                  )

      return(response)
    end
    alias :req :get_request
    alias :get :get_request

    # Inserts a key into riak, using RpbPutReq.
    # @option options [Fixnum] :w (write quorum) how many replicas to write to before returning a successful response.
    # @option options [Fixnum :dw how many replicas to commit to durable storage before returning a successful response.
    # @option options [Boolean] :return_body whether to return the contents of the stored object.
    # @return [RpbPutResp] the response confirming Key storage and (optionally) the Key's updated/new data.
    def put_request(options)
      raise ArgumentError, t('invalid_bucket')  if options[:bucket].empty?
      raise ArgumentError, t('empty_content')   if options[:content].nil?
      options[:w]           ||= @write_quorum   unless @write_quorum.nil?
      options[:dw]          ||= @replica_commit unless @replica_commit.nil?
      options[:return_body]   = @return_body    unless options.has_key?(:return_body)

      request   = Riak::RpbPutReq.new(options.slice :bucket, :key, :vclock, :content, :w, :dw, :return_body)
      response  = rpc.request(
                    Util::MessageCode::PUT_REQUEST,
                    request
                  )

      return(true)      if response == ""
      return(response)
    end

    # Deletes a key, using RpbDelReq, from within a given bucket, from Riak.
    # @param [String] bucket the bucket from which to delete the key
    # @param [String] key the name of the key to be deleted
    # @param [Fixnum] rw how many replicas to delete before returning a successful response
    # @return [RpbGetResp] the response confirming deletion
    def del_request(bucket, key, rw=nil)
      request         = Riak::RpbDelReq.new
      request.bucket  = bucket
      request.key     = key
      request.rw    ||= rw

      response        = rpc.request(
                          Util::MessageCode::DEL_REQUEST,
                          request
                        )

      return(true)      if response == ""
      return(response)
    end

    # Sends a MapReduce operation to riak, using RpbMapRedReq, and returns the Response/phases.
    # @param [String] mr_request map/reduce job, encoded/stringified
    # @param [String] content_type encoding for map/reduce job
    # @return [RpbMapRedResp] the response, encoded in the same format that was sent
    def map_reduce_request(mr_request, content_type)
      request               = Riak::RpbMapRedReq.new
      request.request       = mr_request
      request.content_type  = content_type

      response              = rpc.request(
                                Util::MessageCode::MAP_REDUCE_REQUEST,
                                request
                              )

      return(response)
    end
    alias :mapred :map_reduce_request
    alias :mr     :map_reduce_request

    # Lists the buckets found in the Riak database
    # @raise [ReturnRespError] if the message response does not correlate with the message requested
    # @return [Array] list of buckets (String)
    def buckets
      response = rpc.request Util::MessageCode::LIST_BUCKETS_REQUEST

      # iterate through each of the Strings in the Bucket list, returning an array of String(s)
      @buckets = response.buckets.each{|b| b}
    end

    # Lists the keys within their respective buckets, that are found in the Riak database
    # @param [String] bucket the bucket from which to retrieve the list of keys
    # @raise [ReturnRespError] if the message response does not correlate with the message requested
    # @return [Hash] Mapping of the buckets (String) to their keys (Array of Strings)
    def keys_in(bucket)
      list_keys_request = RpbListKeysReq.new(:bucket => bucket)

      response = rpc.request Util::MessageCode::LIST_KEYS_REQUEST, list_keys_request

      return(response.keys.each{|k| k})
    end

    # @return [String] A representation suitable for IRB and debugging output.
#      def inspect
#        "#<Client >"
#      end

    private
    def b64encode(n)
      Base64.encode64([n].pack("N")).chomp
    end

  end # class Client
end # module Riak


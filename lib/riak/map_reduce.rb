require 'riak'

module Riak
  # Class for invoking map-reduce jobs using the HTTP interface.
  class MapReduce
    include Util::Translation
    # @return [Array<[bucket,key]>,String] The bucket/keys for input to the job, or the bucket (all keys).
    # @see #add
    attr_accessor :inputs

    # @return [Array<Phase>] The map and reduce phases that will be executed
    # @see #map
    # @see #reduce
    # @see #link
    attr_accessor :query

    # Creates a new map-reduce job.
    # @param [Client] client the Riak::Client interface
    # @yield [self] helpful for initializing the job
    def initialize(client)
      @client, @inputs, @query = client, [], []
      yield self if block_given?
    end

    # Add or replace inputs for the job.
    # @overload add(bucket)
    #   Run the job across all keys in the bucket.  This will replace any other inputs previously added.
    #   @param [String, Bucket] bucket the bucket to run the job on
    # @overload add(bucket,key)
    #   Add a bucket/key pair to the job.
    #   @param [String,Bucket] bucket the bucket of the object
    #   @param [String] key the key of the object
    # @overload add(object)
    #   Add an object to the job (by its bucket/key)
    #   @param [Key] object the object to add to the inputs
    # @overload add(bucket, key, keydata)
    #   @param [String,Bucket] bucket the bucket of the object
    #   @param [String] key the key of the object
    #   @param [String] keydata extra data to pass along with the object to the job
    # @return [MapReduce] self
    def add(*params)
      params = params.dup.flatten
      case params.size
      when 1
        p = params.first
        case p
        when Riak::Bucket
          @inputs = p.name
        when Riak::Key
          @inputs << p.to_input
        when String
          @inputs = p
        end
      when 2..3
        bucket = params.shift
        bucket = bucket.name if Riak::Bucket === bucket
        @inputs << params.unshift(bucket)
      end
      self
    end
    alias :<< :add
    alias :include :add

    # Add a map phase to the job.
    # @overload map(function)
    #   @param [String, Array] function a Javascript function that represents the phase, or an Erlang [module,function] pair
    # @overload map(function?, options)
    #   @param [String, Array] function a Javascript function that represents the phase, or an Erlang [module, function] pair
    #   @param [Hash] options extra options for the phase (see {Phase#initialize})
    # @return [MapReduce] self
    # @see Phase#initialize
    def map(*params)
      options = params.extract_options!
      @query << Phase.new({:type => :map, :function => params.shift}.merge(options))
      self
    end

    # Add a reduce phase to the job.
    # @overload reduce(function)
    #   @param [String, Array] function a Javascript function that represents the phase, or an Erlang [module,function] pair
    # @overload reduce(function?, options)
    #   @param [String, Array] function a Javascript function that represents the phase, or an Erlang [module, function] pair
    #   @param [Hash] options extra options for the phase (see {Phase#initialize})
    # @return [MapReduce] self
    # @see Phase#initialize
    def reduce(*params)
      options = params.extract_options!
      @query << Phase.new({:type => :reduce, :function => params.shift}.merge(options))
      self
    end

    # Add a link phase to the job. Link phases follow links attached to objects automatically (a special case of map).
    # @param [Hash] params represents the types of links to follow
    # @return [MapReduce] self
    def walk(params={})
      bucket  ||= params[:bucket]
      tag     ||= params[:tag]
      keep      = params[:keep] || false

      function  = {
        "link"    => {}
      }
      function["link"]["bucket"]  = bucket  unless bucket.nil?
      function["link"]["tag"]     = tag     unless tag.nil?

      @query << Phase.new({:type => :link, :function => function, :keep => keep})

      return(self)
    end
    alias :link :walk

    # Sets the timeout for the map-reduce job.
    # @param [Fixnum] value the job timeout, in milliseconds
    def timeout(value)
      @timeout = value
    end

    # Convert the job to JSON for submission over the HTTP interface.
    # @return [String] the JSON representation
    def to_json(options={})
      hash = {"inputs" => inputs, "query" => query.map(&:as_json)}
      hash['timeout'] = @timeout.to_i if @timeout
      ActiveSupport::JSON.encode(hash, options)
    end

    # Executes this map-reduce job.
    # @return [Array<Array>] similar to link-walking, each element is an array of results from a phase where "keep" is true. If there is only one "keep" phase, only the results from that phase will be returned.
    def run
      response = @client.map_reduce_request(to_json, "application/json")
#      ActiveSupport::JSON.decode(response[:body])
    end

    # Represents an individual phase in a map-reduce pipeline. Generally you'll want to call
    # methods of {MapReduce} instead of using this directly.
    class Phase
      include Util::Translation
      # @return [Symbol] the type of phase - :map, :reduce, or :link
      attr_accessor :type

      # @return [String, Array<String, String>, Hash, WalkSpec] For :map and :reduce types, the Javascript function to run (as a string or hash with bucket/key), or the module + function in Erlang to run. For a :link type, a {Riak::WalkSpec} or an equivalent hash.
      attr_accessor :function

      # @return [String] the language of the phase's function - "javascript" or "erlang". Meaningless for :link type phases.
      attr_accessor :language

      # @return [Boolean] whether results of this phase will be returned
      attr_accessor :keep

      # @return [Array] any extra static arguments to pass to the phase
      attr_accessor :arg

      # Creates a phase in the map-reduce pipeline
      # @param [Hash] options options for the phase
      # @option options [Symbol] :type one of :map, :reduce, :link
      # @option options [String] :language ("javascript") "erlang" or "javascript"
      # @option options [String, Array, Hash] :function In the case of Javascript, a literal function in a string, or a hash with :bucket and :key. In the case of Erlang, an Array of [module, function].  For a :link phase, a hash including any of :bucket, :tag or a WalkSpec.
      # @option options [Boolean] :keep (false) whether to return the results of this phase
      # @option options [Array] :arg (nil) any extra static arguments to pass to the phase
      def initialize(options={})
        self.type = options[:type]
        self.language = options[:language] || "javascript"
        self.function = options[:function]
        self.keep = options[:keep] || false
        self.arg = options[:arg]
      end

      def type=(value)
        raise ArgumentError, t("invalid_phase_type") unless value.to_s =~ /^(map|reduce|link)$/i
        @type = value.to_s.downcase.to_sym
      end

      def function=(value)
        case value
        when Array
          raise ArgumentError, t("module_function_pair_required") unless value.size == 2
          @language = "erlang"
        when Hash
          raise ArgumentError, t("stored_function_invalid") unless type == :link || value.has_key?(:bucket) && value.has_key?(:key)
          @language = "javascript"
        when String
          @language = "javascript"
        else
          raise ArgumentError, t("invalid_function_value", :value => value.inspect)
        end
        @function = value
      end

      # Converts the phase to JSON for use while invoking a job.
      # @return [String] a JSON representation of the phase
      def to_json(options=nil)
        ActiveSupport::JSON.encode(as_json, options)
      end

      # Converts the phase to its JSON-compatible representation for job invocation.
      # @return [Hash] a Hash-equivalent of the phase
      def as_json(options=nil)
        obj = case type
              when :map, :reduce
                defaults = {"language" => language, "keep" => keep}
                case function
                when Hash
                  defaults.merge(function)
                when String
                  if function =~ /\s*function/
                    defaults.merge("source" => function)
                  else
                    defaults.merge("name" => function)
                  end
                when Array
                  defaults.merge("module" => function[0], "function" => function[1])
                end
              when :link
                function
              end
        obj["arg"] = arg if arg
        { type => obj }
      end
    end
  end
end

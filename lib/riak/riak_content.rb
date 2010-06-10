require 'riak'
require 'set'

module Riak
  # Parent class of all object types supported by ripple. {Riak::RObject} represents
  # the data and metadata stored in a bucket/key pair in the Riak database.
  class RiakContent
    include Util::Translation
    include Util::MessageCode

    attr_accessor   :key

    # @return [String] the data stored in Riak at this object's key.  Varies in format by content-type.
    attr_accessor   :value
    alias_attribute :data, :value

    # @return [String] the MIME content type of the object
    attr_accessor   :content_type

    # @return [String] the charset of the object
    attr_accessor   :charset

    # @return [String] the content encoding of the object
    attr_accessor   :content_encoding

    # @return [String] the vtag of the object
    attr_accessor   :vtag

    # @return [Set<Link>] an Set of {Riak::Link} objects for relationships between this object and other resources
    attr_accessor   :links

    # @return [Time] the Last-Modified header from the most recent HTTP response, useful for caching and reloading
    attr_accessor   :last_mod
    alias_attribute :last_modified, :last_mod

    # @return [Time] the Last-Modified header from the most recent HTTP response, useful for caching and reloading
    attr_accessor   :last_mod_usecs
    alias_attribute :last_modified_usecs, :last_mod_usecs

    # @return [Hash] a hash of any user-supplied metadata, consisting of a key/value pair
    attr_accessor   :usermeta
    alias_attribute :meta, :usermeta

    # Create a new riak_content object manually
    # @see Key#content
    def initialize(key=nil, contents={})
#      options.assert_valid_keys(:value, :data, :content_type, :charset, :content_encoding)

      @key              = key unless key.nil?
      @links            = Set.new
      @_links           = []
      @usermeta         = {}

      load(contents) unless contents.empty?

      yield self if block_given?
    end

    # Load information for the content from the response object, Riak::RpbContent.
    #
    # @param [RpbContent/Hash] contents an RpbContent object or a Hash.
    # @return [RiakContent] self
    def load(contents)
      if contents.is_a?(Riak::RpbContent) or contents.is_a?(Hash)
        @content_type     = contents[:content_type]     unless contents[:content_type].empty?
        @charset          = contents[:charset]          unless contents[:charset].empty?
        @content_encoding = contents[:content_encoding] unless contents[:content_encoding].empty?
        @vtag             = contents[:vtag]             unless contents[:vtag].empty?
        self.links        = contents[:links]            unless contents[:links].empty?
        @last_mod         = contents[:last_mod]
        @last_mod_usecs   = contents[:last_mod_usecs]
        self.usermeta     = contents[:usermeta]         unless contents[:usermeta].empty?

        case @content_type
        when /json/
          @value = ActiveSupport::JSON.decode(contents[:value]) unless contents[:value].empty?
        when /octet/
          @value = Marshal.load(contents[:value]) unless contents[:value].empty?
        else
          @value = contents[:value] unless contents[:value].nil?
        end

        return(self)
      end

      raise ArgumentError, t("riak_content_type")
    end

    # Save the RiakContent instance in riak.
    # @option options [Fixnum] w (write quorum) how many replicas to write to before returning a successful response
    # @option options [Fixnum] dw how many replicas to commit to durable storage before returning a successful response
    # @option options [true/false] return_body whether or not to have riak return the key, once saved.  default = true
    def save(options={})
      begin
        save!(options)
      rescue FailedRequest
        return(false)
      end
      return(true)
    end

    # Save the RiakContent instance in riak.  Raise/do not rescue on failure.
    # @option options [Fixnum] w (write quorum) how many replicas to write to before returning a successful response
    # @option options [Fixnum] dw how many replicas to commit to durable storage before returning a successful response
    # @option options [true/false] return_body whether or not to have riak return the key, once saved.  default = true
    def save!(options={})
      options[:content] = self
      return(true) if @key.save(options)
      return(false) # Create and raise Error message for this?  Extend "Failed Request"?
    end

    def link_key(bucket, key, tag)
    end

    def links=(pb_links)
      @links.clear
      @_links.clear

      pb_links.each do |pb_link|
        if @key.nil?
#          link  = [pb_link.tag, pb_link.bucket, pb_link.key]
          link = _link = [pb_link.tag, pb_link.bucket, pb_link.key]
        else
          link  = [pb_link.tag, @key.get_linked(pb_link.bucket, pb_link.key, {:safely => true})]
          _link = [pb_link.tag, pb_link.bucket, pb_link.key]
        end

        @links.add(link)
        @_links << _link
      end

      return(@links)
    end

    def links
      @links
    end

    # @return [Riak::RpbContent] An instance of a RpbContent, suitable for protobuf exchange
    def to_pb
      rpb_content                   = Riak::RpbContent.new

      links                         = []
      @links.each do |link|
        pb_link       = link[1].to_pb_link
        pb_link[:tag] = link[0]
        links << pb_link
      end

      usermeta                      = []
      @usermeta.each do |key,value|
        pb_pair         =   Riak::RpbPair.new
        pb_pair[:key]   =   key
        pb_pair[:value] =   value
        usermeta        <<  pb_pair
      end

      catch(:redo) do
        case @content_type
        when /octet/
          rpb_content.value = Marshal.dump(@value) unless @value.nil?
        when /json/
          rpb_content.value = ActiveSupport::JSON.encode(@value) unless @value.nil?
        when "", nil
          @content_type     = "application/json"
          redo
        else
          rpb_content.value = @value.to_s unless @value.nil?
        end
      end

      rpb_content.content_type      = @content_type     unless @content_type.nil?
      rpb_content.charset           = @charset          unless @charset.nil? # || @charset.empty?
      rpb_content.content_encoding  = @content_encoding unless @content_encoding.nil? # || @content_encoding.empty?
      rpb_content.vtag              = @vtag             unless @vtag.nil?
      rpb_content.links             = links             unless links.empty?
      rpb_content.usermeta          = usermeta          unless usermeta.empty?

      return(rpb_content)
    end

    # @return [String] A representation suitable for IRB and debugging output
    def inspect
      "#<#Riak::RiakContent " + [
          (@value.nil?)             ? nil : "value=#{@value.inspect}",
          (@content_type.nil?)      ? nil : "content_type=#{@content_type.inspect}",
          (@charset.nil?)           ? nil : "charset=#{@charset.inspect}",
          (@content_encoding.nil?)  ? nil : "content_encoding=#{@content_encoding.inspect}",
          (@vtag.nil?)              ? nil : "vtag=#{@vtag.inspect}",
          (@links.nil?)             ? nil : "links=#{@_links.inspect}",
          (@last_mod.nil?)          ? nil : "last_mod=#{last_mod.inspect}",
          (@last_mod_usecs.nil?)    ? nil : "last_mod_usecs=#{last_mod_usecs.inspect}",
          (@usermeta.nil?)          ? nil : "usermeta=#{@usermeta.inspect}"

        ].compact.join(", ") + ">"
    end

    private

  end # class RiakContent
end # module Riak

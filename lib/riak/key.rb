require 'riak'

module Riak
  # Represents and encapsulates operations on a Riak bucket.  You may retrieve a bucket
  # using {Client#bucket}, or create it manually and retrieve its meta-information later.
  class Key
    include Util::Translation
    include Util::MessageCode

    # @return [Riak::Client] the associated client
    attr_reader :bucket

    # @return [String] the bucket name
    attr_reader :name

    # @return [String] the bucket name
    attr_reader :vclock

    # Create a Riak bucket manually.
    # @param [Bucket] bucket the Bucket object within which this Key exists
    # @option options [String] name the name assigned to this Key entity
    # @option options [Fixnum] vclock Careful! Do not set this unless you have a reason to
    # @option options [RiakContent] content a content object, that's to be inserted in this Key
    def initialize(bucket, key, get_response=nil)
#      options.assert_valid_keys(:name, :vclock, :content)

      self.bucket   = bucket
      self.name     = key

      @contents     = Hash.new{|k,v| k[v] = Riak::RiakContent.new(self)}

#      @contents[:new]

      load(get_response) unless get_response.nil?
    end

    # Load information for the key from the response object, Riak::RpbGetResp.
    #
    # @param [RpbGetResp/Hash] response an RpbGetResp/RpbPutResp object or a Hash.
    # @return [Key] self
    def load(response)
      @blargh = response
      raise ArgumentError, t("response_type") unless response.is_a?(Protobuf::Message)

      self.vclock       = response.vclock if response.has_field?(:vclock)

      if response.has_field?(:content)
        self.content    = response.content
      elsif @contents.blank?
        @contents[:new]
      end

      return(self)
    end

    # Load information for the key from Riak::RpbGetResp object.
    #
    # @param [RpbGetResp/Hash] response an RpbGetResp/RpbPutResp object or a Hash.
    # @return [Key] self
    def load!(response)
      raise ArgumentError, t("response_type") unless response.is_a?(Riak::RpbGetResp)

      if response.has_field?(:vclock) and response.has_field?(:content)

        self.vclock   = response.vclock
        self.content  = response.content

      elsif response.has_field?(:vclock) or response.has_field?(:content)
        raise MalformedKeyError # This should never happen

      else
        raise KeyNotFoundError

      end

      return(self)
    end

    # Indicates whether or not the Key is empty
    # @return [Boolean] true or false, whether or not the vclock/content is empty
    def empty?
      return(true) if @vclock.blank? && @contents.nil?
      return(false)
    end

    # Refreshes the Key and its content with fresh data, if there's concern that separate updates may have taken place.
    # @return 
    def reload!

    end

    # Retrieves any Keys that are linked to, inside RiakContent elements.
    # @return [Key] the Key to which the RiakContent is linked (may be empty if it does not exist)
    def get_linked(bucket, key, options={})
      @bucket.get_linked(bucket, key, options)
    end

    # Sets the name attribute for this Key object
    # @param [String] key_name sets the name of the Key
    # @return [Hash] the properties that were accepted
    # @raise [FailedRequest] if the new properties were not accepted by the Riak server
    def name=(key_name)
      raise ArgumentError, t("key_name_type") unless key_name.is_a?(String)

      @name = key_name
    end

    # Sets the content object for this Key.  I do not yet support siblings in this method and, therefore,
    #  you may or may not destroy them if you use this and are not careful.
    # @param [Riak::RiakContent] content a RiakContent instance that should be contained within this Key
    # @return [Riak::RiakContent] the RiakContent instance that was just set
    # @raise [ArgumentError] will yell at you if the supplied riak_content is not of the RiakContent class
    def content=(riak_contents)

      if riak_contents.is_a?(Protobuf::Field::FieldArray)
        @contents.clear
        
        return(false) if riak_contents.empty?

        riak_contents.each do |rc|
          @contents[rc.vtag].load(rc)
        end
        
        return(true)
      elsif riak_contents.is_a?(Riak::RiakContent)

        @contents.clear

        @contents[riak_contents.vtag].load(riak_contents)

      elsif riak_contents.nil?
        @contents.clear

      else
        raise ArgumentError, t("riak_content_type")
      end # if riak_contents

    end # def content=

    # "@contents" is an array of RiakContent objects, though only contains more than one in the event that
    #   there are siblings.
    # @return [Riak::RiakContent] the content of this Key instance's value (ie, key/value)
    def content
      case @contents.size
      when 0 then @contents[:new]
      when 1 then contents[0]
      else        contents
      end
    end

    # "@contents" is an array of RiakContent objects.  This gives you that entire array.
    # @return [Array<Riak::RiakContent>] the contents of this Key instance's value and its siblings, if any
    def contents
      retr_c = []

      @contents.each{|k,v| retr_c << v}

      return(retr_c)
    end

    # Save the Key+RiakContent instance in riak.
    # @option options [RiakContent] content RiakContent instance to be saved in this Key.  Must be specified if there are siblings.
    # @option options [Fixnum] w (write quorum) how many replicas to write to before returning a successful response
    # @option options [Fixnum] dw how many replicas to commit to durable storage before returning a successful response
    # @option options [Boolean] return_body whether or not to have riak return the key, once saved.  default = true
    # TODO: Add in content checking, perhaps?
    def save(options={})
      rcontent = options[:content]

      if rcontent.nil?
        case contents.size
        when 0 then raise ArgumentError, t('empty_content')
        when 1 then rcontent = contents[0]
        else        raise SiblingError.new(self.name)
        end
      end

      options[:content] = rcontent.to_pb  if      rcontent.is_a?(Riak::RiakContent)
      options[:content] = rcontent        if      rcontent.is_a?(Riak::RpbContent)
      options[:key]     = @name
      options[:vclock]  = @vclock         unless  @vclock.nil?

      begin
        response = @bucket.store(options)
        load(response)
        return(true) if @contents.count == 1
        return(false)
      rescue FailedRequest
        return(false)
      end
    end

    # Save the RiakContent instance in riak.  Raise/do not rescue on failure.
    # @option options [Fixnum] w (write quorum) how many replicas to write to before returning a successful response
    # @option options [Fixnum] dw how many replicas to commit to durable storage before returning a successful response
    # @option options [Boolean] return_body whether or not to have riak return the key, once saved.  default = true
    def save!(options={})
      begin
        save(options)
        return(true) if @contents.count == 1
        raise FailedRequest.new("save_resp_siblings", 1, @contents.count, @contents) if @contents.count > 1
      rescue FailedRequest
        raise FailedRequest.new("save_resp_err")
      end
    end

    # Creates an RpbPutReq instance, to be shipped off to riak and saved
    # @option options [Fixnum] w (write quorum) how many replicas to write to before returning a successful response
    # @option options [Fixnum] dw how many replicas to commit to durable storage before returning a successful response
    # @option options [Boolean] return_body whether or not to have riak return the key, once saved.  default = true
    # @return [Riak::RpbPutReq]
    def to_pb_put(options={})
      rcontent    = options[:content]

      if rcontent.nil?
        case contents.size
        when 0 then raise ArgumentError, t('empty_content')
        when 1 then rcontent = contents[0]
        else        raise SiblingError.new(self.name)
        end
      end

      pb_put_req              = Riak::RpbPutReq.new
      pb_put_req.key          = @name
      pb_put_req.content      = rcontent.to_pb  if      rcontent.is_a?(Riak::RiakContent)
      pb_put_req.content      = rcontent        if      rcontent.is_a?(Riak::RpbContent)
      pb_put_req.vclock       = @vclock         unless  @vclock.nil?

      return(pb_put_req)
    end

    # "@contents" is an array of RiakContent objects.  This gives you that entire array.
    # @return [Riak::RpbLink]
    def to_pb_link
      pb_link = Riak::RpbLink.new
      pb_link[:bucket]  = @bucket.name
      pb_link[:key]     = @name

      return(pb_link)
    end

    # Converts this Key into an array, that can be used by a RiakContent, if desired.
    # @return [Array] contains the name of the bucket and the name of the key
    def to_link
      [@bucket.name, @name]
    end
    alias :to_input :to_link

    # Deletes this key from its Bucket container
    # @param [Hash] options quorum options
    # @option options [Fixnum] :rw - the read/write quorum for the delete
    def delete(options={})
      bucket.delete(@name, options)
    end

    # @return [String] a representation suitable for IRB and debugging output
    def inspect
      "#<Riak::Key name=#{@name.inspect}, vclock=#{@vclock.inspect}, contents=#{contents.inspect}>"
    end

    private

    # Sets the name attribute for this Key object
    # @param [String] key_name sets the name of the Key
    # @return [Hash] the properties that were accepted
    # @raise [FailedRequest] if the new properties were not accepted by the Riak server
    def bucket=(bucket)
      raise ArgumentError, t("invalid_bucket") unless bucket.is_a?(Riak::Bucket)

      @bucket ||= bucket
    end

    # Sets the vclock attribute for this Key, which was supplied by the Riak node (if you're doing it right)
    # @param [Fixnum] vclock the vector clock
    # @return [Fixnum] the vector clock
    # @raise [ArgumentError] if you failed at this task, you'll be instructed to place your head on the keyboard
    def vclock=(vclock)
      raise ArgumentError, t("vclock_type") unless vclock.is_a?(String)

      @vclock = vclock
    end

  end # class Key
end # module Riak

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
      
      @contents     = Hash.new{|k,v| k[v] = Riak::RiakContent.new}
      
      @contents[:new]
      
      load(get_response) unless get_response.nil?
    end

    # Load information for the key from the response object, Riak::RpbGetResp.
    #
    # @param [RpbGetResp/Hash] response an RpbGetResp object or a Hash.
    # @return [Key] self
    def load(get_response)
      raise ArgumentError, t("response_type") unless get_response.is_a?(Riak::RpbGetResp)
      
      self.vclock       = get_response.vclock if get_response.has_field?(:vclock)
      
      if get_response.has_field?(:content)
        self.content    = get_response.content
      else
        @contents[:new]
      end
      
      return(self)
    end
    
    # Load information for the key from Riak::RpbGetResp object.
    #
    # @param [RpbGetResp/Hash] response an RpbGetResp object or a Hash.
    # @return [Key] self
    def load!(get_response)
      raise ArgumentError, t("response_type") unless get_response.is_a?(Riak::RpbGetResp)
      
      if get_response.has_field?(:vclock) and get_response.has_field?(:content)
        
        self.vclock   = get_response.vclock
        self.content  = get_response.content
        
      elsif get_response.has_field?(:vclock) or get_response.has_field?(:content)
        raise MalformedKeyError # This should never happen
        
      else
        raise KeyNotFoundError
        
      end
      
      return(self)
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
        raise NoContentError if riak_contents.empty?

        @contents.clear
        
        riak_contents.each do |rc|
          @contents[rc.vtag].load(rc)
        end
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

    def save(params=nil)
      
    end

    def save!(params=nil)
      
    end

    # Creates an RpbPutReq instance, to be shipped off to riak and saved
    # @return [Riak::RpbPutReq] 
    def to_pb_put(params={})
      content     = params[:content]
      write_q     = params[:w]  || params[:quorum]
      write_d     = params[:dw] || params[:durable]
      return_body = params[:rb] || params[:return_body] || true
      
      if content.nil? and contents.size == 1
        content = contents[0]
      elsif content.nil?
        raise SiblingError.new(self.name)
      end

      pb_put_req          = Riak::RpbPutReq.new
      pb_put_req.content  = content.to_pb if      content.is_a?(Riak::RiakContent)
      pb_put_req.content  = content       if      content.is_a?(Riak::RpbContent)
      pb_put_req.vclock   = @vclock       unless  @vclock.nil?
      

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
      raise ArgumentError, t("bucket_type") unless bucket.is_a?(Riak::Bucket)
      
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

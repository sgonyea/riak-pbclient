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

    # @return [Riak::Client] the associated client
    attr_reader :bucket

    # @return [String] the bucket name
    attr_reader :name
    
    # @return [Array<RiakContent>] From the PBC API:
    attr_reader :contents
    #  content - value+metadata entries for the object. If there are siblings there will be
    #              more than one entry. If the key is not found, content will be empty.
    #  https://wiki.basho.com/display/RIAK/PBC+API
    
    # @return [String] the bucket name
    attr_reader :vclock
    
    # Create a Riak bucket manually.
    # @param [Bucket] bucket the Bucket object within which this Key exists
    # @option options [String] name the name assigned to this Key entity
    # @option options [Fixnum] vclock Careful! Do not set this unless you have a reason to
    # @option options [RiakContent] content a content object, that's to be inserted in this Key
    def initialize(bucket, options={})
      options.assert_valid_keys(:name, :vclock, :content)
      
      self.bucket   = bucket
      self.name     = options[:name]
      self.vclock   = options[:vclock]
      self.content  = options[:content]
    end

    # Load information for the key from either the response object, Riak::RpbGetResp, or
    #  from a Hash object that you supply yourself.
    #
    # Fills in the RpbContent object and the vclock value.  Notice -
    #  This class is not forcing you to fill in the "name" attribute, but you need
    #  to do it at some point.  If you use the handlers, it should largely be done for you.
    #
    # @param [RpbGetResp/Hash] response an RpbGetResp object or a Hash.
    # @return [Key] self
    def load(response={})
      options.assert_valid_keys(:vclock, :content)
      
      self.vclock   = response[:vclock]
      self.content  = response[:content]
      
      self
    end

    # Sets the name attribute for this Key object
    # @param [String] key_name sets the name of the Key
    # @return [Hash] the properties that were accepted
    # @raise [FailedRequest] if the new properties were not accepted by the Riak server
    def name=(key_name)
      raise ArgumentError, t("string_type") unless key_name.is_a?(String)
      
      warn  "name is already set to'#{@name}'; setting to '#{key_name}'.  " +
            "Renaming is not yet supported.  May result in duplicate keys." if @name
      
      @name = key_name
    end
    
    # Sets the vclock attribute for this Key, which was supplied by the Riak node (if you're doing it right)
    # @param [Fixnum] vclock the vector clock
    # @return [Fixnum] the vector clock
    # @raise [ArgumentError] if you failed at this basic task, you'll be instructed to place your head on the keyboard
    def vclock=(vclock)
      raise ArgumentError, t("fixnum_type") unless vclock.is_a?(Fixnum)
      
      @vclock = vclock
    end
    
    # Sets the content object for this Key.  I do not yet support siblings in this method and, therefore,
    #  you may or may not destroy them if you use this and are not careful.
    # @param [Riak::RiakContent] content a RiakContent instance that should be contained within this Key
    # @return [Riak::RiakContent] the RiakContent instance that was just set
    # @raise [ArgumentError] will yell at you if the supplied riak_content is not of the RiakContent class
    def content=(riak_content)
      raise ArgumentError, t("riak_content_type") unless riak_content.is_a?(Riak::RiakContent)
      
      warn  "the content within this key appears to have siblings.  " +
            "if you're sure, please use content!" if @contents.size > 1
      
      @contents = [riak_content] unless @contents.size > 1
    end
    
    # Sets the content object for this Key, by force.  Will override the potentially annoying warning message
    #  regarding the existence of siblings.  Please shower me with suggestions on how to handle this.
    # @param [Riak::RiakContent] content a RiakContent instance that should be contained within this Key
    # @return [Riak::RiakContent] the RiakContent instance that was just set
    # @raise [ArgumentError] if you failed at this basic task, you'll be instructed to place your head on the keyboard
    def content!(riak_content)
      raise ArgumentError, t("riak_content_type") unless riak_content.is_a?(Riak::RiakContent)
      
      @contents = [riak_content]
    end
    
    # "@contents" is an array of RiakContent objects, though only contains more than one in the event that
    #   there are siblings.
    # @return [Riak::RiakContent] the content of this Key instance's value (ie, key/value)
    def content
      return(@contents[0])
    end
    
    # "@contents" is an array of RiakContent objects.  This gives you that entire array.
    # @return [Array<Riak::RiakContent>] the contents of this Key instance's value- and any of that content's siblings, if they were requested
    def contents
      return(@contents)
    end

    # Deletes this key from its Bucket container
    # @param [Hash] options quorum options
    # @option options [Fixnum] :rw - the read/write quorum for the delete
    def delete(options={})
      bucket.delete(@name, options)
    end

    # @return [String] a representation suitable for IRB and debugging output
#    def inspect
#      "#<Riak::Key #{" keys=[#{keys.join(',')}]" if defined?(@keys)}>"
#    end
    
    private
    
    # Sets the name attribute for this Key object
    # @param [String] key_name sets the name of the Key
    # @return [Hash] the properties that were accepted
    # @raise [FailedRequest] if the new properties were not accepted by the Riak server
    def bucket=(bucket)
      raise ArgumentError, t("bucket_type") unless bucket.is_a?(Riak::Bucket)
      
      @bucket ||= bucket
    end
    
  end # class Key
end # module Riak

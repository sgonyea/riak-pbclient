# Copyright 2010, Scott Gonyea
#
#                 Shamelessly lifted/massaged from:
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
require 'set'

module Riak
  # Parent class of all object types supported by ripple. {Riak::RObject} represents
  # the data and metadata stored in a bucket/key pair in the Riak database.
  class RiakContent
    include Util::Translation
    include Util::MessageCode
    
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
    def initialize(contents={})
#      options.assert_valid_keys(:value, :data, :content_type, :charset, :content_encoding)
      
      @value            = contents[:value]
      @value          ||= contents[:data]
      @charset          = contents[:charset]
      @content_type     = contents[:content_type]
      @content_encoding = contents[:content_encoding]
      
      @links, @meta = Set.new, {}
      yield self if block_given?
    end
    
    def load(contents)
      raise ArgumentError, t("riak_content_type") unless contents.is_a?(Riak::RpbContent)
      
      @value            = contents[:value]
      @content_type     = contents[:content_type]
      @charset          = contents[:charset]
      @content_encoding = contents[:content_encoding]
      @vtag             = contents[:vtag]
#      self.links        = contents[:links]
      @last_mod         = contents[:last_mod]
      @last_mod_usecs   = contents[:last_mod_usecs]
#      self.usermeta     = contents[:usermeta]
      
    end

    # @return [String] A representation suitable for IRB and debugging output
    def inspect
      "#<#Riak::RiakContent " + [
          (@value.nil?)             ? nil : "value=#{@value.inspect}",
          (@content_type.nil?)      ? nil : "content_type=#{@content_type.inspect}",
          (@charset.nil?)           ? nil : "charset=#{@charset.inspect}",
          (@content_encoding.nil?)  ? nil : "content_encoding=#{@content_encoding.inspect}",
          (@vtag.nil?)              ? nil : "vtag=#{@vtag.inspect}",
          (@links.nil?)             ? nil : "links=#{@links.inspect}",
          (@last_mod.nil?)          ? nil : "last_mod=#{last_mod.inspect}",
          (@last_mod_usecs.nil?)    ? nil : "last_mod_usecs=#{last_mod_usecs.inspect}",
          (@usermeta.nil?)          ? nil : "usermeta=#{@usermeta.inspect}"
          
        ].compact.join(", ") + ">"
    end

    private

  end # class RiakContent
end # module Riak

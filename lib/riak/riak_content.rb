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
    
    # @return [String] the Riak vector clock for the object
    attr_accessor   :vclock
    alias_attribute :vector_clock, :vclock
    
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
    def initialize(options={})
      options.assert_valid_keys(:value, :data, :content_type, :charset, :content_encoding)
      
      @value            = options[:value]
      @value          ||= options[:data]
      @charset          = options[:charset]
      @content_type     = options[:content_type]
      @content_encoding = options[:content_encoding]
      
      @links, @meta = Set.new, {}
      yield self if block_given?
    end

    # Delete the object from Riak and freeze this instance.  Will work whether or not the object actually
    # exists in the Riak database.
    def delete
      return if key.blank?
      @bucket.delete(key)
      freeze
    end

    # @return [true,false] Whether this object has conflicting sibling objects (divergent vclocks)
    def conflict?
      @conflict.present?
    end

    # @return [String] A representation suitable for IRB and debugging output
#    def inspect
#      "#<#{self.class.name} [#{@content_type}]:#{@data.inspect}>"
#    end

    def expose_attribute(rpb_content, attr_name)
      create_method("#{attr_name}")   do
        return(rpb_content[attr_name])
      end
      
      create_method("#{attr_name}=")  do |value|
        rpb_content[attr_name] = value
      end
    end # expose_attribute
    
    def create_method(name, &block)
     self.class.send(:define_method, name, &block)
    end

    private

  end # class RiakContent
end # module Riak

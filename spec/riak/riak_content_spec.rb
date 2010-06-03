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
require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Riak::RiakContent do
  describe "when directly initializing" do
    before :each do
      @client = Riak::Client.new
      @bucket = @client["goog"]
      @key    = Riak::Key.new(@bucket, "test")
    end

    it "should default with nil attributes and links/usermeta as instances of Set/Hash" do
      rcontent                          =   Riak::RiakContent.new
      rcontent.key.should               ==  nil
      rcontent.value.should             ==  nil
      rcontent.content_type.should      ==  nil
      rcontent.charset.should           ==  nil
      rcontent.content_encoding.should  ==  nil
      rcontent.vtag.should              ==  nil
      rcontent.links.should             be_kind_of(Set)
      rcontent.last_mod.should          ==  nil
      rcontent.last_mod_usecs.should    ==  nil
      rcontent.usermeta.should          be_kind_of(Hash)
    end

    it "should allow you to set the Key, after initialization" do
      rcontent                          =   Riak::RiakContent.new
      rcontent.key                      =   @key
      rcontent.key.should               ==  @key
    end

    it "should accept a Key as an argument to new, tying it back to an owner" do
      rcontent                          =   Riak::RiakContent.new(@key)
      rcontent.key.should               ==  @key
    end

    it "should serialize into a corresponding Protocol Buffer (RpbContent)" do
      rcontent                          =   Riak::RiakContent.new
      rcontent.to_pb.should             be_kind_of(Riak::RpbContent)
    end
    
    it "should load a Riak::RpbContent instance, returning a matching self, RiakContent" do
      rcontent                          =   Riak::RiakContent.new(@key)
      rpb_content                       =   Riak::RpbContent.new
#      rpb_content.value                 =   "{\"Date\":\"2010-04-12\",\"Open\":567.35,\"High\":574.00,\"Low\":566.22,\"Close\":572.73,\"Volume\":2352400,\"Adj. Close\":572.73}"
#      rpb_content.content_type          =   "application/json"
#      rpb_content.vtag                  =   "4DNB6Vt0zLl5VJ6P2xx9dc"
#      rpb_content.last_mod              =   1274645855
#      rpb_content.last_mod_usecs        =   968694

      rcontent.load(rpb_content)
      rcontent.key.should               ==  @key
#      rcontent.value.should             ==  "{\"Date\":\"2010-04-12\",\"Open\":567.35,\"High\":574.00,\"Low\":566.22,\"Close\":572.73,\"Volume\":2352400,\"Adj. Close\":572.73}"
#      rcontent.content_type.should      ==  "application/json"
      rcontent.charset.should           ==  nil
      rcontent.content_encoding.should  ==  nil
#      rcontent.vtag.should              ==  "4DNB6Vt0zLl5VJ6P2xx9dc"
      rcontent.links.should             be_kind_of(Set)
#      rcontent.last_mod.should          ==  1274645855
#      rcontent.last_mod_usecs.should    ==  968694
      rcontent.usermeta.should          be_kind_of(Hash)
    end
    
  end # describe "when directly initializing"
end # Riak::RiakContent

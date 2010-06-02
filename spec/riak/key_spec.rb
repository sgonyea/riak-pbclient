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

describe Riak::Key do
  describe "when directly initializing" do
    before :each do
      @client = Riak::Client.new
      @bucket = @client["goog"]
    end

    it "should default with the bucket and name, and an empty vclock" do
      key                 =   Riak::Key.new(@bucket, "test")
      key.bucket.should   ==  @bucket
      key.name.should     ==  "test"
      key.vclock.should   ==  nil
      key.content.should  be_kind_of(Riak::RiakContent)
    end

    it "should serialize into a Key Protocol Buffer (RpbPutReq)" do
      key                   =   @bucket["2010-04-12"] # Riak::Key.new(@bucket, "test")
      pb_put                =   key.to_pb_put
      pb_put.should         be_kind_of(Riak::RpbPutReq)
#      pb_put.vclock.should  ==  "k\xCEa```\xCC`\xCA\x05R,\xACL\xF7^e0%2\xE6\xB12\xC4s\xE6\x1D\xE5\xCB\x02\x00"
    end

    it "should serialize into a Link Protocol Buffer (RpbLink)" do
      key                   =   Riak::Key.new(@bucket, "test")
      pb_link               =   key.to_pb_link
      pb_link.should        be_kind_of(Riak::RpbLink)
      pb_link.bucket.should ==  "goog"
      pb_link.key.should    ==  "test"
    end
  end # describe "when directly initializing"
end # Riak::Key


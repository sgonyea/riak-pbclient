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

describe Riak::Bucket do
  describe "when directly initializing" do
    before :each do
      @client = Riak::Client.new
    end

    it "should default with the client and name, and empty n_val or allow_mult" do
      bucket = Riak::Bucket.new(@client, "test")
      bucket.client.should      == @client
      bucket.name.should        == "test"
      bucket.n_val.should       == nil
      bucket.allow_mult.should  == nil
    end

    it "should correctly accept an n_val" do
      bucket                    = Riak::Bucket.new(@client, "test")
      bucket.n_val              = 5
      bucket.n_val.should       be_kind_of(Fixnum)
      lambda { bucket.n_val="5" }.should raise_error(ArgumentError)
    end

    it "should correctly accept an allow_mult" do
      bucket                    = Riak::Bucket.new(@client, "test")
      bucket.allow_mult         = true
      bucket.allow_mult.should  be_kind_of(TrueClass)
      bucket.allow_mult         = false
      bucket.allow_mult.should  be_kind_of(FalseClass)
      lambda { bucket.allow_mult="no" }.should  raise_error(ArgumentError)
    end
  end # describe "when directly initializing"

  describe "when initialized from the Client" do
    before :each do
      @client = Riak::Client.new
    end

    it "should have set the properties" do
      bucket = @client["goog"]
      bucket.should             be_kind_of(Riak::Bucket)
      bucket.client.should      == @client
      bucket.name.should        == "goog"
      bucket.n_val.should       be_kind_of(Fixnum)
      bucket.allow_mult.should  == false
    end
  end # describe "when initialized from the Client"

  describe "key retrieval" do
    before :each do
      @client = Riak::Client.new
      @bucket = @client["goog"]
    end

    it "should list the keys within the bucket" do
      @bucket.keys.should be_kind_of(Protobuf::Field::FieldArray)
    end

    it "should return a key, when requested" do
      @bucket["2010-04-12"].should be_kind_of(Riak::Key)
    end
  end # describe "key retrieval"

end # Riak::Client

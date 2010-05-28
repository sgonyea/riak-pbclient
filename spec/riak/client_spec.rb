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

describe Riak::Client do
  describe "when initializing" do
    it "should default to the local interface on port 8087" do
      client = Riak::Client.new
      client.host.should      == "127.0.0.1"
      client.port.should      == 8087
      client._buckets.should  == []
    end

    it "should accept a host" do
      client = Riak::Client.new :host => "riak.basho.com"
      client.host.should == "riak.basho.com"
    end

    it "should accept a port" do
      client = Riak::Client.new :port => 9000
      client.port.should == 9000
    end
  end

  describe "reconfiguring" do
    before :each do
      @client = Riak::Client.new
    end

    describe "setting the host" do
      it "should allow setting the host" do
        @client.should respond_to(:host=)
        @client.host = "riak.basho.com"
        @client.host.should == "riak.basho.com"
      end

      it "should require the host to be an IP or hostname" do
        [238472384972, "", "riak.basho-.com"].each do |invalid|
          lambda { @client.host = invalid }.should raise_error(ArgumentError)
        end
        ["127.0.0.1", "10.0.100.5", "localhost", "otherhost.local", "riak.basho.com"].each do |valid|
          lambda { @client.host = valid }.should_not raise_error
        end
      end
    end # describe "setting the host"

    describe "setting the port" do
      it "should allow setting the port" do
        @client.should respond_to(:port=)
        @client.port = 9000
        @client.port.should == 9000
      end

      it "should require the port to be a valid number" do
        [-1,65536,"foo"].each do |invalid|
          lambda { @client.port = invalid }.should raise_error(ArgumentError)
        end
        [0,1,65535,8098].each do |valid|
          lambda { @client.port = valid }.should_not raise_error
        end
      end
    end # describe "setting the port"

    describe "setting the client id" do
=begin
      it "should accept a string unmodified" do
        @client.client_id = "foo"
        @client.client_id.should == "foo"
      end

      it "should base64-encode an integer" do
        @client.client_id = 1
        @client.client_id.should == "AAAAAQ=="
      end

      it "should reject an integer equal to the maximum client id" do
        lambda { @client.client_id = Riak::Client::MAX_CLIENT_ID }.should raise_error(ArgumentError)
      end

      it "should reject an integer larger than the maximum client id" do
        lambda { @client.client_id = Riak::Client::MAX_CLIENT_ID + 1 }.should raise_error(ArgumentError)
      end
=end
    end # describe "setting the client id"
  end # describe "reconfiguring"

  describe "sending and receiving protocol buffers" do
    before :each do
      @client = Riak::Client.new
    end
    
    describe "basic communication with riak node" do
      it "should send a ping request and return true" do
        @client.ping?.should          == true
      end
      
      it "should request the connected riak node's server info and return a Hash" do
        # test length or content?  Need to look at what are considered acceptable values
        @client.info[:node].should            be_kind_of(String)
        @client.info[:server_version].should  be_kind_of(String)
      end
    end # describe "basic communication with riak node"

    describe "bucket operations and retrieval" do
      it "should send a request to list available bucket names and return a Protobuf::Field::FieldArray" do
        @client.buckets.should be_kind_of(Protobuf::Field::FieldArray)
      end
      
      it "should send a request with the bucket name and return a Riak::Bucket" do
        @client.bucket("goog").should be_kind_of(Riak::Bucket)
      end
      
      it "should send a request to list keys within a bucket and return a Protobuf::Field::FieldArray" do
        @client.keys_in("goog").should be_kind_of(Protobuf::Field::FieldArray)
      end
    end # describe "bucket operations and retrieval"
    
    describe "key operations and retrieval" do
      it "should send a request for a bucket/key pair and return a Riak::RpbGetResp" do
        @client.get_request("goog", "2010-04-12").should be_kind_of(Riak::RpbGetResp)
      end
      
      it "should have a vclock attribute within Riak::RpbGetResp of that is a String" do
        @client.get_request("goog", "2010-04-12").vclock.should be_kind_of(String)
      end
    end # describe "key operations and retrieval"
    
  end # describe "basic communication with riak node"
end # Riak::Client

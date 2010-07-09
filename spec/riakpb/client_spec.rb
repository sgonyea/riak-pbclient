require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Riakpb::Client do
  describe "when initializing" do
    it "should default to the local interface on port 8087" do
      client = Riakpb::Client.new
      client.host.should      == "127.0.0.1"
      client.port.should      == 8087
    end

    it "should accept a host" do
      client = Riakpb::Client.new :host => "riak.basho.com"
      client.host.should == "riak.basho.com"
    end

    it "should accept a port" do
      client = Riakpb::Client.new :port => 9000
      client.port.should == 9000
    end
  end

  describe "reconfiguring" do
    before :each do
      @client = Riakpb::Client.new
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
      it "should accept a string unmodified" do
        @client.client_id = "foo"
        @client.client_id.should == "foo"
      end

      it "should base64-encode an integer" do
        @client.client_id = 1
        @client.client_id.should == "AAAAAQ=="
      end

      it "should reject an integer equal to the maximum client id" do
        lambda { @client.client_id = Riakpb::Client::MAX_CLIENT_ID }.should raise_error(ArgumentError)
      end

      it "should reject an integer larger than the maximum client id" do
        lambda { @client.client_id = Riakpb::Client::MAX_CLIENT_ID + 1 }.should raise_error(ArgumentError)
      end
    end # describe "setting the client id"
  end # describe "reconfiguring"

  describe "sending and receiving protocol buffers" do
    before :each do
      @client = Riakpb::Client.new
      @client.rpc.stub!(:status).and_return(true)
      @client.rpc.stub!(:request).and_return(nil)
    end

    describe "basic communication with riak node" do
      it "should send a ping request and return true" do
        @client.rpc.stub!(:request).with(
            Riakpb::Util::MessageCode::PING_REQUEST
          ).and_return('')

        @client.ping?.should          == true
      end

      it "should request the connected riak node's server info and return a Hash" do
        # test length or content?  Need to look at what are considered acceptable values
        @client.rpc.stub!(:request).with(
            Riakpb::Util::MessageCode::GET_SERVER_INFO_REQUEST
          ).and_return(Riakpb::RpbGetServerInfoResp.new(
            {   :node           => "riak@127.0.0.1",
                :server_version => "0.10.1"
            }
          ))

        @client.info[:node].should            be_kind_of(String)
        @client.info[:server_version].should  be_kind_of(String)
      end
    end # describe "basic communication with riak node"

    describe "bucket operations: retrieval (get) and send (set)" do

      describe "bucket retrieval (get)" do
        it "should send a request to list available bucket names and return a Protobuf::Field::FieldArray" do
          @client.rpc.stub!(:request).with(
              Riakpb::Util::MessageCode::LIST_BUCKETS_REQUEST
            ).and_return(
              Riakpb::RpbListBucketsResp.new(
                {   :buckets => ["goog"] }
            ))

          @client.buckets.should be_kind_of(Protobuf::Field::FieldArray)
        end

        it "should send a request with the bucket name and return a Riakpb::Bucket" do
          @client.rpc.stub!(:request).with(
              Riakpb::Util::MessageCode::GET_BUCKET_REQUEST,
              Riakpb::RpbGetBucketReq.new(:bucket => "goog")
            ).and_return(
              Riakpb::RpbGetBucketResp.new(
                {   :props  => {
                    :allow_mult => false,
                    :n_val      => 3
                    }
                }
            ))

          @client.bucket("goog").should be_kind_of(Riakpb::Bucket)
        end

        it "should send a request to list keys within a bucket and return a Protobuf::Field::FieldArray" do
          @client.rpc.stub!(:request).with(
              Riakpb::Util::MessageCode::LIST_KEYS_REQUEST,
              Riakpb::RpbListKeysReq.new(:bucket => "goog")
            ).and_return(
              Riakpb::RpbListKeysResp.new(
                {   :keys =>  ["2010-04-12", "2008-01-10", "2006-06-06"],
                    :done =>  true
                }
            ))
          @client.keys_in("goog").should be_kind_of(Protobuf::Field::FieldArray)
        end
      end # describe "bucket retrieval (get)"

      describe "bucket sending (set)" do
      end # describe "bucket sending (set)"
    end # describe "bucket operations and retrieval"

    describe "key operations: retrieval (get), send (put) and delete (del)" do
      before :each do
        @client.rpc.stub!(:request).with(
            Riakpb::Util::MessageCode::GET_REQUEST,
            Riakpb::RpbGetReq.new(:bucket => "goog", :key => "2010-04-12", :r => nil)
          ).and_return(
            Riakpb::RpbGetResp.new(
              {   :content  =>  [],
                  :vclock   =>  ""
              }
          ))
      end

      it "should send a request for a bucket/key pair and return a Riakpb::RpbGetResp" do
        @client.get_request("goog", "2010-04-12").should be_kind_of(Riakpb::RpbGetResp)
      end

      it "should have a vclock attribute within Riakpb::RpbGetResp of that is a String" do
        @client.get_request("goog", "2010-04-12").vclock.should be_kind_of(String)
      end
    end # describe "key operations and retrieval"

    describe "key operations and retrieval" do
      before :each do
        @client.rpc.stub!(:request).with(
            Riakpb::Util::MessageCode::GET_REQUEST,
            Riakpb::RpbGetReq.new(:bucket => "goog", :key => "2010-04-12", :r => nil)
          ).and_return(
            Riakpb::RpbGetResp.new(
              {   :content  =>  [],
                  :vclock   =>  ""
              }
          ))
      end


    end # describe "key operations and retrieval"
  end # describe "basic communication with riak node"
end # Riakpb::Client

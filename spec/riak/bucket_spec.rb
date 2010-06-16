require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Riak::Bucket do
  describe "when directly initializing" do
    before :each do
      @client = Riak::Client.new
      @client.stub!(:set_bucket).and_return(true)
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
      @client.rpc.stub!(:request).and_return(nil)
    end

    it "should have set the properties" do
      @client.rpc.stub!(:request).with(
          Riak::Util::MessageCode::GET_BUCKET_REQUEST,
          Riak::RpbGetBucketReq.new(:bucket => "goog")
        ).and_return(
          Riak::RpbGetBucketResp.new(
            {   :props  => {
                :allow_mult => false,
                :n_val      => 3
                }
            }
        ))
      bucket = @client["goog"]
      bucket.should             be_kind_of(Riak::Bucket)
      bucket.client.should      == @client
      bucket.name.should        == "goog"
      bucket.n_val.should       == 3
      bucket.allow_mult.should  == false
    end
  end # describe "when initialized from the Client"

  describe "key retrieval" do
    before :each do
      @client = Riak::Client.new
      @client.rpc.stub!(:request).with(
          Riak::Util::MessageCode::GET_BUCKET_REQUEST,
          Riak::RpbGetBucketReq.new(:bucket => "goog")
        ).and_return(
          Riak::RpbGetBucketResp.new(
            {   :props  => {
                :allow_mult => false,
                :n_val      => 3
                }
            }
        ))
      @bucket = @client["goog"]
    end

    it "should list the keys within the bucket" do
      @client.rpc.stub!(:request).with(
          Riak::Util::MessageCode::LIST_KEYS_REQUEST,
          Riak::RpbListKeysReq.new(:bucket => "goog")
        ).and_return(
          Riak::RpbListKeysResp.new(
            {   :keys =>  ["2010-04-12", "2008-01-10", "2006-06-06"],
                :done =>  true
            }
        ))
      @bucket.keys.should be_kind_of(Protobuf::Field::FieldArray)
    end

    it "should return a key, when requested" do
      @client.rpc.stub!(:request).with(
          Riak::Util::MessageCode::GET_REQUEST,
          Riak::RpbGetReq.new(:bucket => "goog", :key => "2010-04-12", :r => nil)
        ).and_return(
          Riak::RpbGetResp.new(
            {   :content  =>  [],
                :vclock   =>  ""
            }
        ))
      @bucket["2010-04-12"].should be_kind_of(Riak::Key)
    end
  end # describe "key retrieval"

end # Riak::Client

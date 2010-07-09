require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Riakpb::Key do
  describe "when directly initializing" do
    before :each do
      @client = Riakpb::Client.new
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
      @bucket = @client["goog"]
    end

    it "should default with the bucket and name, and an empty vclock" do
      key                 =   Riakpb::Key.new(@bucket, "test")
      key.bucket.should   ==  @bucket
      key.name.should     ==  "test"
      key.vclock.should   ==  nil
      key.content.should  be_kind_of(Riakpb::Content)
    end

    it "should serialize into a Key Protocol Buffer (RpbPutReq)" do
      @client.rpc.stub!(:request).with(
          Riakpb::Util::MessageCode::GET_REQUEST,
          Riakpb::RpbGetReq.new(:bucket => "goog", :key => "2010-04-12", :r => nil)
        ).and_return(
          Riakpb::RpbGetResp.new(
            {   :content  =>  [Riakpb::RpbContent.new(:value => "Test")],
                :vclock   =>  "k\xCEa```\xCC`\xCA\x05R,\xACL\xF7^e0%2\xE6\xB12\xC4s\xE6\x1D\xE5\xCB\x02\x00"
            }
        ))
      key                   =   @bucket["2010-04-12"] # Riakpb::Key.new(@bucket, "test")
      pb_put                =   key.to_pb_put
      pb_put.should         be_kind_of(Riakpb::RpbPutReq)
      pb_put.vclock.should  ==  "k\xCEa```\xCC`\xCA\x05R,\xACL\xF7^e0%2\xE6\xB12\xC4s\xE6\x1D\xE5\xCB\x02\x00"
    end

    it "should serialize into a Link Protocol Buffer (RpbLink)" do
      key                   =   Riakpb::Key.new(@bucket, "test")
      pb_link               =   key.to_pb_link
      pb_link.should        be_kind_of(Riakpb::RpbLink)
      pb_link.bucket.should ==  "goog"
      pb_link.key.should    ==  "test"
    end
  end # describe "when directly initializing"
end # Riakpb::Key


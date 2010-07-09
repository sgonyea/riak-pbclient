require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Riakpb::Content do
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
      @key    = Riakpb::Key.new(@bucket, "test")
    end

    it "should default with nil attributes and links/usermeta as instances of Set/Hash" do
      rcontent                          =   Riakpb::Content.new(@key)
      rcontent.key.should               ==  @key
      rcontent.value.should             ==  nil
      rcontent.content_type.should      ==  nil
      rcontent.charset.should           ==  nil
      rcontent.content_encoding.should  ==  nil
      rcontent.vtag.should              ==  nil
      rcontent.links.should             be_kind_of(Hash)
      rcontent.last_mod.should          be_kind_of(Time)
      rcontent.last_mod_usecs.should    ==  nil
      rcontent.usermeta.should          be_kind_of(Hash)
    end

    it "should allow you to set the Key, after initialization" do
      rcontent                          =   Riakpb::Content.new(@key)
      rcontent.key                      =   @key
      rcontent.key.should               ==  @key
    end

    it "should accept a Key as an argument to new, tying it back to an owner" do
      rcontent                          =   Riakpb::Content.new(@key)
      rcontent.key.should               ==  @key
    end

    it "should serialize into a corresponding Protocol Buffer (RpbContent)" do
      rcontent                          =   Riakpb::Content.new(@key, :value => "Test")
      rcontent.to_pb.should             be_kind_of(Riakpb::RpbContent)
    end
    
    it "should load a Riakpb::RpbContent instance, returning a matching self, Content" do
      rcontent                          =   Riakpb::Content.new(@key)
      rpb_content                       =   Riakpb::RpbContent.new
      rpb_content.value                 =   "{\"Date\":\"2010-04-12\",\"Open\":567.35,\"High\":574.00,\"Low\":566.22,\"Close\":572.73,\"Volume\":2352400,\"Adj. Close\":572.73}"
      rpb_content.content_type          =   "application/json"
      rpb_content.vtag                  =   "4DNB6Vt0zLl5VJ6P2xx9dc"
      rpb_content.last_mod              =   1274645855
      rpb_content.last_mod_usecs        =   968694

      rcontent.load(rpb_content)
      rcontent.key.should               ==  @key
      rcontent.value.should             ==  {"Date" => "2010-04-12".to_date,"Open" => 567.35,"High" => 574.00,"Low" => 566.22,"Close" => 572.73,"Volume" => 2352400,"Adj. Close" => 572.73}
      rcontent.content_type.should      ==  "application/json"
      rcontent.charset.should           ==  nil
      rcontent.content_encoding.should  ==  nil
      rcontent.vtag.should              ==  "4DNB6Vt0zLl5VJ6P2xx9dc"
      rcontent.links.should             be_kind_of(Hash)
      rcontent.last_mod.should          ==  Time.at(1274645855.968694)
      rcontent.usermeta.should          be_kind_of(Hash)
    end

  end # describe "when directly initializing"
end # Riakpb::Content

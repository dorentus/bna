describe "bnet-authenticator-load" do
  before do
    @🔐 = Bnet::Authenticator.new 'CN-1402-1943-1283', '4202aa2182640745d8a807e0fe7e34b30c1edb23'
  end

  it "has expected restoration code" do
    @🔐.restorecode.should == '4CKBN08QEB'
  end

  it "calculates token correctly at 1347279358" do
    @🔐.get_token(1347279358).should == ['61459300', 1347279360]
  end

  it "calculates token correctly at 1347279359" do
    @🔐.get_token(1347279359).should == ['61459300', 1347279360]
  end

  it "calculates token correctly at 1347279360" do
    @🔐.get_token(1347279360).should == ['75939986', 1347279390]
  end

  it "calculates token correctly at 1370448000" do
    @🔐.get_token(1370448000).should == ['59914793', 1370448030]
  end
end

describe "bnet-authenticator-networking" do
  it "can request for server time" do
    timestamp = Bnet::Authenticator.request_server_time :EU
    (Time.now.getutc.to_i - timestamp).abs.should <= 30
  end

  it "can request for a new authenticator" do
    🔐 = Bnet::Authenticator.request_authenticator :US
    🔐.region.should == :US
  end

  it "can restore an anthenticator" do
    🔐 = Bnet::Authenticator.restore_authenticator 'CN-1402-1943-1283', '4CKBN08QEB'
    🔐.secret.should == '4202aa2182640745d8a807e0fe7e34b30c1edb23'
  end
end

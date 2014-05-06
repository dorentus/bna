describe "battlenet-authenticator" do
  before do
    @authenticator = Bnet::Authenticator.new 'CN-1402-1943-1283', '4202aa2182640745d8a807e0fe7e34b30c1edb23'
  end

  it "has expected restoration code" do
    @authenticator.restorecode.should == '4CKBN08QEB'
  end

  it "calculates token correctly" do
    @authenticator.get_token(1347279358).should == ['61459300', 1347279360]
    @authenticator.get_token(1347279359).should == ['61459300', 1347279360]
    @authenticator.get_token(1347279360).should == ['75939986', 1347279390]
    @authenticator.get_token(1370448000).should == ['59914793', 1370448030]
  end
end

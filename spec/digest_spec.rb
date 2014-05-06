describe "NSData+Digest" do
  it "calculate SHA1 hash correctly" do
    "1".to_data.SHA1HexDigest.should == "356a192b7913b04c54574d18c28d46e6395428ab"
    "\xD5^\vD\x97\xBBL\x8D[\x05\x04\xA0\v\x98\xCC6o+$\xE1".to_data.SHA1HexDigest.should == "15714dbb066e5379b6d4fd70f061dbf0b4a0978b"
  end

  it "caculate HMAC SHA1 hash correctly" do
    "aaa".to_data.HMACSHA1HexDigestWithKey("bbb".to_data).should == "7480bfb8a50d1c8797cb137e9258d1c899713b1d"
  end
end

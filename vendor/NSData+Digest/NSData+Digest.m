#import "NSData+Digest.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSData (Digest)
- (NSData *)SHA1Digest
{
  NSMutableData *result = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
  CC_SHA1(self.bytes, self.length, result.mutableBytes);
  return result;
}

- (NSData *)HMACSHA1DigestWithKey:(NSData *)keyData
{
  NSMutableData *result = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
  CCHmac(kCCHmacAlgSHA1, keyData, keyData.length, self, self.length, result.mutableBytes);
  return result;
}

- (NSString *)to_hex
{
  NSMutableString *result = [NSMutableString stringWithCapacity:self.length * 2];
  const unsigned char *bytes = [self bytes];
  for (int i = 0, n = self.length; i < n; ++i) {
    [result appendFormat:@"%02x", bytes[i]];
  }
  return result;
}

- (NSString *)SHA1HexDigest
{
  return [[self SHA1Digest] to_hex];
}

- (NSString *)HMACSHA1HexDigestWithKey:(NSData *)keyData
{
  return [[self HMACSHA1DigestWithKey:keyData] to_hex];
}
@end

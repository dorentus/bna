#import <Foundation/Foundation.h>

@interface NSData (Digest)
- (NSData *)SHA1Digest;
- (NSData *)HMACSHA1DigestWithKey:(NSData *)keyData;
- (NSString *)to_hex;
- (NSString *)SHA1HexDigest;
- (NSString *)HMACSHA1HexDigestWithKey:(NSData *)keyData;
@end

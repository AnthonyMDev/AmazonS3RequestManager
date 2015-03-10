//
//  AmazonS3SignatureHelpers.m
//  AmazonS3RequestManager
//
// Copyright (c) 2015 Anthony Miller
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "AmazonS3SignatureHelpers.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation AmazonS3SignatureHelpers

+ (NSString *)encodedSignatureForSignature:(NSString *)signature withSecret:(NSString *)secret
{
  return @"";
}

+ (NSData *)HMACSHA1EncodedDataFromString:(NSString *)string withKey:(NSString *)key
{
  NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
  CCHmacContext context;
  const char *keyCString = [key cStringUsingEncoding:NSASCIIStringEncoding];
  
  CCHmacInit(&context, kCCHmacAlgSHA1, keyCString, strlen(keyCString));
  CCHmacUpdate(&context, [data bytes], [data length]);
  
  unsigned char digestRaw[CC_SHA1_DIGEST_LENGTH];
  NSUInteger digestLength = CC_SHA1_DIGEST_LENGTH;
  
  CCHmacFinal(&context, digestRaw);
  
  return [NSData dataWithBytes:digestRaw length:digestLength];
}

+ (NSString *)Base64EncodedStringFromData:(NSData *)data
{
  NSUInteger length = [data length];
  NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
  
  uint8_t *input = (uint8_t *)[data bytes];
  uint8_t *output = (uint8_t *)[mutableData mutableBytes];
  
  for (NSUInteger i = 0; i < length; i += 3) {
    NSUInteger value = 0;
    for (NSUInteger j = i; j < (i + 3); j++) {
      value <<= 8;
      if (j < length) {
        value |= (0xFF & input[j]);
      }
    }
    
    static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    NSUInteger idx = (i / 3) * 4;
    output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
    output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
    output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
    output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
  }
  
  return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

@end

//
//  AmazonS3SignatureHelpers.m
//  AmazonS3RequestManager
//
// Based on `AFAmazonS3Manager` by `Matt Thompson`
//
// Created by Anthony Miller. 2015.
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

+ (NSString *)AmazonS3URLPathForURL:(NSURL *)url {
    NSString *cfPath = (NSString*)CFBridgingRelease(CFURLCopyPath((CFURLRef)url));
    NSString *path = [cfPath AMS3_decodeURLEncoding];
    
    if (path.length == 0) {
        path = [NSString stringWithFormat:@"/"];
    }
    
    return path;
}

+ (NSData *)hash:(NSData *)dataToHash {
    if ([dataToHash length] > UINT32_MAX) {
        return nil;
    }
    
    const void *cStr = [dataToHash bytes];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(cStr, (uint32_t)[dataToHash length], result);
    
    return [[NSData alloc] initWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
}

+ (NSString *)hexEncode:(NSString *)string {
    NSUInteger len = [string length];
    unichar *chars = malloc(len * sizeof(unichar));
    
    [string getCharacters:chars];
    
    NSMutableString *hexString = [NSMutableString new];
    for (NSUInteger i = 0; i < len; i++) {
        if ((int)chars[i] < 16) {
            [hexString appendString:@"0"];
        }
        [hexString appendString:[NSString stringWithFormat:@"%x", chars[i]]];
    }
    free(chars);
    
    return hexString;
}

+ (NSString *)hashString:(NSString *)stringToHash {
    return [[NSString alloc] initWithData:[self hash:[stringToHash dataUsingEncoding:NSUTF8StringEncoding]]
                                 encoding:NSASCIIStringEncoding];
}

+ (NSData *)sha256HMacForString:(NSString *)string withKey:(NSData *)key encoding:(NSUInteger)encoding {
    NSData *data = [string dataUsingEncoding:encoding];
    CCHmacContext context;
    
    CCHmacInit(&context, kCCHmacAlgSHA256, [key bytes], [key length]);
    CCHmacUpdate(&context, [data bytes], [data length]);
    
    unsigned char digestRaw[CC_SHA256_DIGEST_LENGTH];
    NSInteger digestLength = CC_SHA256_DIGEST_LENGTH;
    
    CCHmacFinal(&context, digestRaw);
    
    return [NSData dataWithBytes:digestRaw length:digestLength];
}

@end

@implementation NSString (AMS3)

- (NSString *)AMS3_stringWithURLEncodingPath {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSString *decodedString = [self AMS3_decodeURLEncoding];
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)decodedString,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\();:@&=+$,?%#[] ",
                                                                                 kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}

- (NSString *)AMS3_stringWithURLEncodingQuery {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSString *decodedString = [self AMS3_decodeURLEncoding];
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)decodedString,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\/();:%^+@&=$,?%#[] ",
                                                                                 kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}

- (NSString *)AMS3_decodeURLEncoding {
    NSString *result = [self stringByRemovingPercentEncoding];
    return result ? result : self;
}

@end

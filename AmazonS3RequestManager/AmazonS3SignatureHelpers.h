//
//  AmazonS3SignatureHelpers.h
//  AmazonS3RequestManager
//
//  Created by Anthony Miller on 3/5/15.
//  Copyright (c) 2015 Anthony Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AmazonS3SignatureHelpers : NSObject

+ (NSString *)encodedSignatureForSignature:(NSString *)signature withSecret:(NSString *)secret;

@end

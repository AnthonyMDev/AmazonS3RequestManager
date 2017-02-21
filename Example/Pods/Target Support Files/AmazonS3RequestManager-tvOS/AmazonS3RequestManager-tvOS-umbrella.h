#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AmazonS3RequestManager.h"
#import "AmazonS3SignatureHelpers.h"

FOUNDATION_EXPORT double AmazonS3RequestManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char AmazonS3RequestManagerVersionString[];


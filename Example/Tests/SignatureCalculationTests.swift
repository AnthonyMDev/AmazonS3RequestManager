//
//  SignatureCalculationTests.swift
//  AmazonS3RequestManager
//
//  Created by Anthony Miller on 3/2/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

import Nimble

@testable import AmazonS3RequestManager

class SignatureCalculationTests: XCTestCase {
    
    let accessKey = "AKIAIOSFODNN7EXAMPLE"
    let secret = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    let region = AmazonS3Region.USStandard
    
//    func test__GET_request_calculatesSignature() {
//        // given
//        let URL = NSURL(string: "examplebucket.s3.amazonaws.com/test.txt")!
//        let request = NSMutableURLRequest(URL: URL)
//        request.HTTPMethod = "GET"
//        let dateString = "20130524T000000Z"
//        request.setValue(dateString, forHTTPHeaderField: "x-amz-date")
//        request.setValue("bytes=0-9", forHTTPHeaderField: "Range")
//        request.setValue("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
//            forHTTPHeaderField: "x-amz-content-sha256")
//        
//        let expected = "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request,SignedHeaders=host;range;x-amz-content-sha256;x-amz-date,Signature=f0e8bdb87c964420e857bd35b5d6ed310bd44f0170aba48dd91039c6036bdb41"
//        
//        // when
//        let actual = AWSV4SignatureCalculator.V4Signature(request, accessKey: accessKey, secret: secret, region: region)
//        
//        // then
//        expect(actual).to(equal(expected))
//    }
    
}

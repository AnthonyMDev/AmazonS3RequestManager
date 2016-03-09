//
//  AmazonS3RequestSerializerTests.swift
//  AmazonS3RequestManager
//
//  Created by Anthony Miller on 10/14/15.
//  Copyright © 2015 Anthony Miller. All rights reserved.
//

import XCTest

import Nimble

@testable import AmazonS3RequestManager

class AmazonS3RequestSerializerTests: XCTestCase {
    
    var sut: AmazonS3RequestSerializer!
    
    let accessKey = "key"
    let secret = "secret"
    let bucket = "bucket"
    let region = AmazonS3Region.USWest1
    
    override func setUp() {
        super.setUp()
        
        sut = AmazonS3RequestSerializer(accessKey: accessKey, secret: secret, region: region, bucket: bucket)
    }
    
    /*
    *  MARK: - Initialization - Tests
    */
    
    func test__inits__withConfiguredRequestSerializer() {
        expect(self.sut.accessKey).to(equal(self.accessKey))
        expect(self.sut.secret).to(equal(self.secret))
        expect(self.sut.bucket).to(equal(self.bucket))
        expect(self.sut.region).to(equal(self.region))
    }
    
    /*
    *  MARK: Amazon URL Request Serialization - Tests
    */
    
    func test__amazonURLRequest__setsURLWithEndpointURL() {
        // given
        let path = "TestPath"
        let expectedURL = NSURL(string: "https://\(region.endpoint)/\(bucket)/\(path)")!
        
        // when
        let request = sut.amazonURLRequest(.GET, path: path)
        
        // then
        XCTAssertEqual(request.URL!, expectedURL)
    }
    
    func test__amazonURLRequest__givenNoBucket__setsURLWithEndpointURL() {
        // given
        sut.bucket = nil
        
        let path = "TestPath"
        let expectedURL = NSURL(string: "https://\(region.endpoint)/\(path)")!
        
        // when
        let request = sut.amazonURLRequest(.GET, path: path)
        
        // then
        XCTAssertEqual(request.URL!, expectedURL)
    }
    
    func test__amazonURLRequest__givenUseSSL_false_setsURLWithEndpointURL_usingHTTP() {
        // given
        sut.useSSL = false
        
        let path = "TestPath"
        let expectedURL = NSURL(string: "http://\(region.endpoint)/\(bucket)/\(path)")!
        
        // when
        let request = sut.amazonURLRequest(.GET, path: path)
        
        // then
        XCTAssertEqual(request.URL!, expectedURL)
    }
    
    func test__amazonURLRequest__setsHTTPMethod() {
        // given
        let expected = "GET"
        
        // when
        let request = sut.amazonURLRequest(.GET, path: "test")
        
        // then
        XCTAssertEqual(request.HTTPMethod!, expected)
    }
    
    func test__amazonURLRequest__setsCachePolicy() {
        // given
        let expected = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        // when
        let request = sut.amazonURLRequest(.GET, path: "test")
        
        // then
        XCTAssertEqual(request.cachePolicy, expected)
    }
    
    func test__amazonURLRequest__givenNoPathExtension_setsHTTPHeader_ContentType() {
        // given
        let request = sut.amazonURLRequest(.GET, path: "test")
        
        // when
        let headers = request.allHTTPHeaderFields!
        let typeHeader: String? = headers["Content-Type"]
        
        // then
        XCTAssertNotNil(typeHeader, "Should have 'Content-Type' header field")
        XCTAssertEqual(typeHeader!, "application/octet-stream")
    }
    
    func test__amazonURLRequest__givenJPGPathExtension_setsHTTPHeader_ContentType() {
        // given
        let request = sut.amazonURLRequest(.GET, path: "test.jpg")
        
        // when
        let headers = request.allHTTPHeaderFields!
        let typeHeader: String? = headers["Content-Type"]
        
        // then
        XCTAssertNotNil(typeHeader, "Should have 'Content-Type' header field")
        expect(typeHeader).to(equal("image/jpeg"))
    }
    
    func test__amazonURLRequest__givenTXTPathExtension_setsHTTPHeader_ContentType() {
        // given
        let request = sut.amazonURLRequest(.GET, path: "test.txt")
        
        // when
        let headers = request.allHTTPHeaderFields!
        let typeHeader: String? = headers["Content-Type"]
        
        // then
        XCTAssertNotNil(typeHeader, "Should have 'Content-Type' header field")
        XCTAssertEqual(typeHeader!, "text/plain")
    }
    
    func test__amazonURLRequest__givenMarkDownPathExtension_setsHTTPHeader_ContentType() {
        // given
        let request = sut.amazonURLRequest(.GET, path: "test.md")
        
        // when
        let headers = request.allHTTPHeaderFields!
        let typeHeader: String? = headers["Content-Type"]
        
        // then
        XCTAssertNotNil(typeHeader, "Should have 'Content-Type' header field")
        #if os(iOS) || os(watchOS) || os(tvOS)
            expect(typeHeader).to(equal("application/octet-stream"))
        #elseif os(OSX)
            expect(typeHeader).to(equal("text/markdown"))
        #endif
    }
    
    func test__amazonURLRequest__setsHTTPHeader_host() {
        // given
        let request = sut.amazonURLRequest(.GET, path: "test")
        
        // when
        let headers = request.allHTTPHeaderFields!
        let hostHeader: String? = headers["Host"]
        
        // then
        XCTAssertNotNil(hostHeader, "Should have 'Host' header field")
        expect(hostHeader).to(equal(request.URL?.host))
    }
    
    func test__amazonURLRequest__setsHTTPHeader_x_amz_content_sha256() {
        // given
        let request = sut.amazonURLRequest(.GET, path: "test")
        
        // when
        let headers = request.allHTTPHeaderFields!
        let contentHashHeader: String? = headers["x-amz-content-sha256"]
        
        // then
        XCTAssertNotNil(contentHashHeader, "Should have 'x-amz-content-sha256' header field")
        expect(contentHashHeader).to(equal(AWSV4SignatureCalculator.payloadHash(request: request)))
    }
    
    func test__amazonURLRequest__setsHTTPHeader_x_amz_date() {
        // given
        let request = sut.amazonURLRequest(.GET, path: "test")
        
        // when
        let headers = request.allHTTPHeaderFields!
        let dateHeader: String? = headers["x-amz-date"]
        
        // then
        XCTAssertNotNil(dateHeader, "Should have 'x-amz-date' header field")
        XCTAssertTrue(dateHeader!.hasSuffix("Z"))
    }
    
    func test__amazonURLRequest__setsHTTPHeader_Authorization() {
        // given
        let request = sut.amazonURLRequest(.GET, path: "test")
        
        // when
        let headers = request.allHTTPHeaderFields!
        let authHeader: String? = headers["Authorization"]
        
        // then
        XCTAssertNotNil(authHeader, "Should have 'Authorization' header field")
        XCTAssertTrue(authHeader!.hasPrefix("AWS4-HMAC-SHA256 "), "Authorization header should begin with 'AWS4-HMAC-SHA256 '.")
    }
    
    func test__amazonURLRequest__givenACL__setsHTTPHeader_ACL() {
        // given
        let acl = AmazonS3PredefinedACL.Public
        let request = sut.amazonURLRequest(.GET, path: "test", acl: acl)
        
        // when
        let headers = request.allHTTPHeaderFields!
        let aclHeader: String? = headers["x-amz-acl"]
        
        // then
        XCTAssertNotNil(aclHeader, "Should have ACL header field")
    }
    
}

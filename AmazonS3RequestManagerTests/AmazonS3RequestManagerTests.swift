//
//  AmazonS3RequestManagerTests.swift
//  AmazonS3RequestManagerTests
//
//  Created by Anthony Miller on 3/3/15.
//  Copyright (c) 2015 Anthony Miller. All rights reserved.
//

import UIKit
import XCTest

import Alamofire
import AmazonS3RequestManager

class AmazonS3RequestManagerTests: XCTestCase {
  
  var sut: AmazonS3RequestManager!
  
  let accessKey = "key"
  let secret = "secret"
  let bucket = "bucket"
  let region = AmazonS3Region.USWest1

  override func setUp() {
    super.setUp()
    
    sut = AmazonS3RequestManager(bucket: bucket,
      region: region,
      accessKey: accessKey,
      secret: secret)
  }
  
  func test__inits__withValues() {
    XCTAssertEqual(sut.accessKey!, accessKey)
    XCTAssertEqual(sut.secret!, secret)
    XCTAssertEqual(sut.bucket!, bucket)
    XCTAssertEqual(sut.region.rawValue, region.rawValue)
  }
  
  func test__inits__withAmazonConfiguration() {
    // when
    let configuration = sut.session.configuration
    let headers = configuration.HTTPAdditionalHeaders as [String: String]
    let cachePolicyValue = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData.rawValue
    
    // then
    let expectedHeaders = Alamofire.Manager.defaultHTTPHeaders() as [String: String]
    
    XCTAssertEqual(headers, expectedHeaders)
    XCTAssertEqual(configuration.requestCachePolicy.rawValue, cachePolicyValue)
  }
  
  func test__inits__withCustomConfiguration() {
    // given
    let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    
    // when
    sut = AmazonS3RequestManager(bucket: bucket,
      region: region,
      accessKey: accessKey,
      secret: secret,
      configuration: configuration)
    
    // then
    XCTAssertEqual(sut.session.configuration, configuration)
  }
  
  /**
  *  MARK: Endpoint URL - Tests
  */
  
  func test__endpointURL__returnsCorrectURL() {
    // when
    let expectedURL = NSURL(string: "https://\(bucket).\(region.rawValue)")!
    
    // then
    XCTAssertEqual(sut.endpointURL, expectedURL)
  }
  
  func test__endpointURL__givenNoBucket_returnsCorrectURL() {
    // given
    sut.bucket = nil
    
    // when
    let expectedURL = NSURL(string: "https://\(region.rawValue)")!
    
    // then
    XCTAssertEqual(sut.endpointURL, expectedURL)
  }
  
  func test__endpointURL__givenUseSSL_False_returnsCorrectURL() {
    // given
    sut.useSSL = false
    
    // when
    let expectedURL = NSURL(string: "http://\(bucket).\(region.rawValue)")!
    
    // then
    XCTAssertEqual(sut.endpointURL, expectedURL)
  }
  
  /**
  *  MARK: Amazon URL Request Serialization - Tests
  */
  
  func test__amazonURLRequest__setsURLWithEndpointURL() {
    // given
    let path = "TestPath"
    let expectedURL = NSURL(string: "https://\(bucket).\(region.rawValue)/TestPath")!
    
    // when
    let request = sut.amazonURLRequest(.GET, path: path)
    
    // then
    XCTAssertEqual(request.URL, expectedURL)
  }
  
  func test__amazonURLRequest__setsHTTPMethod() {
    // given
    let expected = "GET"
    
    // when
    let request = sut.amazonURLRequest(.GET, path: "test")
    
    // then
    XCTAssertEqual(request.HTTPMethod!, expected)
  }
  
  func test__amazonURLRequest__givenNoPathExtension_setsHTTPHeader_ContentType() {
    // given
    let request = sut.amazonURLRequest(.GET, path: "test")
    
    // when
    let headers = request.allHTTPHeaderFields!
    let typeHeader: String? = headers["Content-Type"] as? String
    
    // then
    XCTAssertNotNil(typeHeader, "Should have 'Content-Type' header field")
    XCTAssertEqual(typeHeader!, "application/octet-stream")
  }
  
  func test__amazonURLRequest__givenJPGPathExtension_setsHTTPHeader_ContentType() {
    // given
    let request = sut.amazonURLRequest(.GET, path: "test.jpg")
    
    // when
    let headers = request.allHTTPHeaderFields!
    let typeHeader: String? = headers["Content-Type"] as? String
    
    // then
    XCTAssertNotNil(typeHeader, "Should have 'Content-Type' header field")
    XCTAssertEqual(typeHeader!, "image/jpeg")
  }
  
  func test__amazonURLRequest__givenTXTPathExtension_setsHTTPHeader_ContentType() {
    // given
    let request = sut.amazonURLRequest(.GET, path: "test.txt")
    
    // when
    let headers = request.allHTTPHeaderFields!
    let typeHeader: String? = headers["Content-Type"] as? String
    
    // then
    XCTAssertNotNil(typeHeader, "Should have 'Content-Type' header field")
    XCTAssertEqual(typeHeader!, "text/plain")
  }
  
  func test__amazonURLRequest__setsHTTPHeader_Date() {
    // given
    let request = sut.amazonURLRequest(.GET, path: "test")
    
    // when
    let headers = request.allHTTPHeaderFields!
    let dateHeader: String? = headers["Date"] as? String
    
    // then
    XCTAssertNotNil(dateHeader, "Should have 'Date' header field")
    XCTAssertTrue(dateHeader!.hasSuffix("GMT"))
  }
  
  func test__amazonURLRequest__setsHTTPHeader_Authorization() {
    // given
    let request = sut.amazonURLRequest(.GET, path: "test")
    
    // when
    let headers = request.allHTTPHeaderFields!
    let authHeader: String? = headers["Authorization"] as? String
    
    // then
    XCTAssertNotNil(authHeader, "Should have 'Authorization' header field")
    XCTAssertTrue(authHeader!.hasPrefix("AWS \(accessKey):"), "Authorization header should begin with 'AWS [accessKey]'.")
  }
  
}

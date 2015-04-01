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
    XCTAssertEqual(sut.endpointURL!, expectedURL)
  }
  
  func test__endpointURL__givenNoBucket_returnsCorrectURL() {
    // given
    sut.bucket = nil
    
    // when
    let expectedURL = NSURL(string: "https://\(region.rawValue)")!
    
    // then
    XCTAssertEqual(sut.endpointURL!, expectedURL)
  }
  
  func test__endpointURL__givenUseSSL_False_returnsCorrectURL() {
    // given
    sut.useSSL = false
    
    // when
    let expectedURL = NSURL(string: "http://\(bucket).\(region.rawValue)")!
    
    // then
    XCTAssertEqual(sut.endpointURL!, expectedURL)
  }
  
}

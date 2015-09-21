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
    
    sut.requestManager.startRequestsImmediately = false
  }
  
  func test__inits__withValues() {
    XCTAssertEqual(sut.accessKey, accessKey)
    XCTAssertEqual(sut.secret, secret)
    XCTAssertEqual(sut.bucket!, bucket)
    XCTAssertEqual(sut.region.rawValue, region.rawValue)
  }
  
  /**
  *  MARK: Endpoint URL - Tests
  */
  
  func test__endpointURL__returnsCorrectURL() {
    // when
    let expectedURL = NSURL(string: "https://\(region.rawValue)/\(bucket)")!
    
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
    let expectedURL = NSURL(string: "http://\(region.rawValue)/\(bucket)")!
    
    // then
    XCTAssertEqual(sut.endpointURL, expectedURL)
  }
  
  /**
  *  MARK: - GET Object Request - Tests
  */
  
  func test__getObject__setsHTTPMethod() {
    // given
    let expected = "GET"
    
    // when
    let request = sut.getObject("test")
    
    // then
    XCTAssertEqual(request.request!.HTTPMethod!, expected)
  }
  
  func test__getObject__setsURLWithEndpoint() {
    // given
    let path = "TestPath"
    let expectedURL = NSURL(string: "https://\(region.rawValue)/\(bucket)/TestPath")!
    
    // when
    let request = sut.getObject(path)
    
    // then
    XCTAssertEqual(request.request!.URL!, expectedURL)
  }
  
  /**
  *  MARK: - Download Object Request - Tests
  */
  
  func test__downloadObject_path_saveToURL_returnsDownloadRequest() {
    // when
    let request = sut.downloadObject("test", saveToURL: NSURL())
    
    // then
    XCTAssertTrue(request.task.isKindOfClass(NSURLSessionDownloadTask))
  }
  
  func test__downloadObject_path_saveToURL_setsHTTPMethod() {
    // given
    let expected = "GET"
    
    // when
    let request = sut.downloadObject("test", saveToURL: NSURL())
    
    // then
    XCTAssertEqual(request.request!.HTTPMethod!, expected)
  }
  
  func test__downloadObject_path_saveToURL_setsURLWithEndpoint() {
    // given
    let path = "TestPath"
    let expectedURL = NSURL(string: "https://\(region.rawValue)/\(bucket)/TestPath")!
    
    // when
    let request = sut.downloadObject(path, saveToURL: NSURL())
    
    // then
    XCTAssertEqual(request.request!.URL!, expectedURL)
  }
  
  /**
  *  MARK: - PUT Object Request - Tests
  */
  
  func test__putObject_fileURL_destinationPath__returnsUploadRequest() {
    // when
    let request = sut.putObject(NSURL(), destinationPath: "path")
    
    // then
    XCTAssertTrue(request.task.isKindOfClass(NSURLSessionUploadTask))
  }
  
  func test__putObject_fileURL_destinationPath_setsHTTPMethod() {
    // given
    let expected = "PUT"
    
    // when
    let request = sut.putObject(NSURL(), destinationPath: "path")
    
    // then
    XCTAssertEqual(request.request!.HTTPMethod!, expected)
  }
  
  func test__putObject_fileURL_destinationPath_setsURLWithEndpoint() {
    // given
    let path = "TestPath"
    let expectedURL = NSURL(string: "https://\(region.rawValue)/\(bucket)/TestPath")!
    
    // when
    let request = sut.putObject(NSURL(), destinationPath: path)
    
    // then
    XCTAssertEqual(request.request!.URL!, expectedURL)
  }
  
  func test__putObject_fileURL_destinationPath__givenACL_setsHTTPHeader_ACL() {
    // given
    let acl = AmazonS3PredefinedACL.Public
    let path = "TestPath"
    
    let request = sut.putObject(NSURL(), destinationPath: path, acl: acl)
    
    // when
    let headers = request.request!.allHTTPHeaderFields!
    let aclHeader: String? = headers["x-amz-acl"]
    
    // then
    XCTAssertNotNil(aclHeader, "Should have ACL header field")
  }
  
  func test__putObject_data_destinationPath__returnsUploadRequest() {
    // when
    let request = sut.putObject(NSData(), destinationPath: "path")
    
    // then
    XCTAssertTrue(request.task.isKindOfClass(NSURLSessionUploadTask))
  }
  
  func test__putObject_data_destinationPath__setsHTTPMethod() {
    // given
    let expected = "PUT"
    
    // when
    let request = sut.putObject(NSData(), destinationPath: "path")
    
    // then
    XCTAssertEqual(request.request!.HTTPMethod!, expected)
  }
  
  func test__putObject_data_destinationPath__setsURLWithEndpoint() {
    // given
    let path = "TestPath"
    let expectedURL = NSURL(string: "https://\(region.rawValue)/\(bucket)/TestPath")!
    
    // when
    let request = sut.putObject(NSData(), destinationPath: path)
    
    // then
    XCTAssertEqual(request.request!.URL!, expectedURL)
  }
  
  func test__putObject_data_destinationPath__givenACL_setsHTTPHeader_ACL() {
    // given
    let acl = AmazonS3PredefinedACL.Public
    let path = "TestPath"
    
    let request = sut.putObject(NSData(), destinationPath: path, acl: acl)
    
    // when
    let headers = request.request!.allHTTPHeaderFields!
    let aclHeader: String? = headers["x-amz-acl"]
    
    // then
    XCTAssertNotNil(aclHeader, "Should have ACL header field")
  }
  
  /**
  *  MARK: DELETE Object Request - Tests
  */
  
  func test__deleteObject_setsHTTPMethod() {
    // given
    let expected = "DELETE"
    
    // when
    let request = sut.deleteObject("test")
    
    // then
    XCTAssertEqual(request.request!.HTTPMethod!, expected)
  }
  
  func test__deleteObject_setsURLWithEndpoint() {
    // given
    let path = "TestPath"
    let expectedURL = NSURL(string: "https://\(region.rawValue)/\(bucket)/TestPath")!
    
    // when
    let request = sut.deleteObject(path)
    
    // then
    XCTAssertEqual(request.request!.URL!, expectedURL)
  }
  
  /**
  *  MARK: - ACL Request - Tests
  */
  
  func test__getBucketACL__setsHTTPMethod() {
    // given
    let expected = "GET"
    
    // when
    let request = sut.getBucketACL()
    
    // then
    XCTAssertEqual(request.request!.HTTPMethod!, expected)
  }
  
  func test__getObject__setsURL_withACLSubresource() {
    // given
    let expectedURL = NSURL(string: "https://\(region.rawValue)/\(bucket)/?acl")!
    
    // when
    let request = sut.getBucketACL()
    
    // then
    XCTAssertEqual(request.request!.URL!, expectedURL)
  }
  
  func test__setBucketACL__setsHTTPMethod() {
    // given
    let expected = "PUT"
    
    let acl = AmazonS3PredefinedACL.Public
    
    // when
    let request = sut.setBucketACL(acl)
    
    // then
    XCTAssertEqual(request.request!.HTTPMethod!, expected)
  }
  
  func test__setBucketACL_setsURLWithEndpoint() {
    // given
    let expectedURL = NSURL(string: "https://\(region.rawValue)/\(bucket)/?acl")!
    
    let acl = AmazonS3PredefinedACL.Public
    
    // when
    let request = sut.setBucketACL(acl)
    
    // then
    XCTAssertEqual(request.request!.URL!, expectedURL)
  }
  
  func test__setBucketACL_setsHTTPHeader_ACL() {
    // given
    let acl = AmazonS3PredefinedACL.Public
    
    // when
    let request = sut.setBucketACL(acl)
    
    let headers = request.request!.allHTTPHeaderFields!
    let aclHeader: String? = headers["x-amz-acl"]
    
    // then
    XCTAssertNotNil(aclHeader, "Should have ACL header field")
  }
  
  func test__getACL_forObjectAtPath__setsHTTPMethod() {
    // given
    let expected = "GET"
    
    // when
    let request = sut.getACL(forObjectAtPath: "test")
    
    // then
    XCTAssertEqual(request.request!.HTTPMethod!, expected)
  }
  
  func test__getACL_forObjectAtPath__setsURL_withACLSubresource() {
    // given
    let path = "TestPath"
    let expectedURL = NSURL(string: "https://\(region.rawValue)/\(bucket)/\(path)?acl")!
    
    // when
    let request = sut.getACL(forObjectAtPath: path)
    
    // then
    XCTAssertEqual(request.request!.URL!, expectedURL)
  }
  
  func test__setACL_forObjectAtPath__setsHTTPMethod() {
    // given
    let expected = "PUT"
    
    let path = "TestPath"
    let acl = AmazonS3PredefinedACL.Public
    
    // when
    let request = sut.setACL(forObjectAtPath: path, acl: acl)
    
    // then
    XCTAssertEqual(request.request!.HTTPMethod!, expected)
  }
  
  func test__setACL_forObjectAtPath__setsURLWithEndpoint() {
    // given
    let path = "TestPath"
    let acl = AmazonS3PredefinedACL.Public
    
    let expectedURL = NSURL(string: "https://\(region.rawValue)/\(bucket)/\(path)?acl")!
    
    // when
    let request = sut.setACL(forObjectAtPath: path, acl: acl)
    
    // then
    XCTAssertEqual(request.request!.URL!, expectedURL)
  }
  
  func test__setACL_forObjectAtPath__setsHTTPHeader_ACL() {
    // given
    let acl = AmazonS3PredefinedACL.Public
    let path = "TestPath"
    
    // when
    let request = sut.setACL(forObjectAtPath: path, acl: acl)
    
    let headers = request.request!.allHTTPHeaderFields!
    let aclHeader: String? = headers["x-amz-acl"]
    
    // then
    XCTAssertNotNil(aclHeader, "Should have ACL header field")
  }
  
  /**
  *  MARK: Amazon URL Request Serialization - Tests
  */
  
  func test__amazonURLRequest__setsURLWithEndpointURL() {
    // given
    let path = "TestPath"
    let expectedURL = NSURL(string: "https://\(region.rawValue)/\(bucket)/TestPath")!
    
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
    XCTAssertEqual(typeHeader!, "image/jpeg")
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
  
  func test__amazonURLRequest__setsHTTPHeader_Date() {
    // given
    let request = sut.amazonURLRequest(.GET, path: "test")
    
    // when
    let headers = request.allHTTPHeaderFields!
    let dateHeader: String? = headers["Date"]
    
    // then
    XCTAssertNotNil(dateHeader, "Should have 'Date' header field")
    XCTAssertTrue(dateHeader!.hasSuffix("GMT"))
  }
  
  func test__amazonURLRequest__setsHTTPHeader_Authorization() {
    // given
    let request = sut.amazonURLRequest(.GET, path: "test")
    
    // when
    let headers = request.allHTTPHeaderFields!
    let authHeader: String? = headers["Authorization"]
    
    // then
    XCTAssertNotNil(authHeader, "Should have 'Authorization' header field")
    XCTAssertTrue(authHeader!.hasPrefix("AWS \(accessKey):"), "Authorization header should begin with 'AWS [accessKey]'.")
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

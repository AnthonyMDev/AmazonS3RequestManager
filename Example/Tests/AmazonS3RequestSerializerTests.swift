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
  let region = Region.USWest1
  
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
    expect(self.sut.region.hostName).to(equal(self.region.hostName))
  }
  
  /*
  *  MARK: Amazon URL Request Serialization - Tests
  */
  
  func test__amazonURLRequest__setsURLWithEndpointURL() {
    // given
    let path = "TestPath"
    let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/\(path)")!
    
    // when
    let request = sut.amazonURLRequest(method: .get, path: path)
    
    // then
    XCTAssertEqual(request.url!, expectedURL)
  }
  
  func test__amazonURLRequest__givenCustomRegion_setsURLWithEndpointURL() {
    // given
    let path = "TestPath"
    let expectedEndpoint = "test.endpoint.com"
    let region = Region.custom(hostName: "", endpoint: expectedEndpoint)
    sut.region = region
    let expectedURL = URL(string: "https://\(expectedEndpoint)/\(bucket)/\(path)")!
    
    // when
    let request = sut.amazonURLRequest(method: .get, path: path)
    
    // then
    XCTAssertEqual(request.url!, expectedURL)
  }
  
  func test__amazonURLRequest__givenNoBucket__setsURLWithEndpointURL() {
    // given
    sut.bucket = nil
    
    let path = "TestPath"
    let expectedURL = URL(string: "https://\(region.endpoint)/\(path)")!
    
    // when
    let request = sut.amazonURLRequest(method: .get, path: path)
    
    // then
    XCTAssertEqual(request.url!, expectedURL)
  }
  
  func test__amazonURLRequest__givenNoPath() {
    // given
    sut.bucket = "test"
    
    let expectedURL = URL(string: "https://\(region.endpoint)/test")!
    
    // when
    let request = sut.amazonURLRequest(method: .get)
    
    // then
    XCTAssertEqual(request.url!, expectedURL)
  }
  
  func test__amazonURLRequest__givenUseSSL_false_setsURLWithEndpointURL_usingHTTP() {
    // given
    sut.useSSL = false
    
    let path = "TestPath"
    let expectedURL = URL(string: "http://\(region.endpoint)/\(bucket)/\(path)")!
    
    // when
    let request = sut.amazonURLRequest(method: .get, path: path)
    
    // then
    XCTAssertEqual(request.url!, expectedURL)
  }
  
  func test__amazonURLRequest__setsHTTPMethod() {
    // given
    let expected = "GET"
    
    // when
    let request = sut.amazonURLRequest(method: .get, path: "test")
    
    // then
    XCTAssertEqual(request.httpMethod!, expected)
  }
  
  func test__amazonURLRequest__setsCachePolicy() {
    // given
    let expected = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
    
    // when
    let request = sut.amazonURLRequest(method: .get, path: "test")
    
    // then
    XCTAssertEqual(request.cachePolicy, expected)
  }
  
  func test__amazonURLRequest__givenNoPathExtension_setsHTTPHeader_ContentType() {
    // given
    let request = sut.amazonURLRequest(method: .get, path: "test")
    
    // when
    let headers = request.allHTTPHeaderFields!
    let typeHeader: String? = headers["Content-Type"]
    
    // then
    XCTAssertNotNil(typeHeader, "Should have 'Content-Type' header field")
    XCTAssertEqual(typeHeader!, "application/octet-stream")
  }
  
  func test__amazonURLRequest__givenJPGPathExtension_setsHTTPHeader_ContentType() {
    // given
    let request = sut.amazonURLRequest(method: .get, path: "test.jpg")
    
    // when
    let headers = request.allHTTPHeaderFields!
    let typeHeader: String? = headers["Content-Type"]
    
    // then
    XCTAssertNotNil(typeHeader, "Should have 'Content-Type' header field")
    expect(typeHeader).to(equal("image/jpeg"))
  }
  
  func test__amazonURLRequest__givenTXTPathExtension_setsHTTPHeader_ContentType() {
    // given
    let request = sut.amazonURLRequest(method: .get, path: "test.txt")
    
    // when
    let headers = request.allHTTPHeaderFields!
    let typeHeader: String? = headers["Content-Type"]
    
    // then
    XCTAssertNotNil(typeHeader, "Should have 'Content-Type' header field")
    XCTAssertEqual(typeHeader!, "text/plain")
  }
  
  func test__amazonURLRequest__givenMarkDownPathExtension_setsHTTPHeader_ContentType() {
    // given
    let request = sut.amazonURLRequest(method: .get, path: "test.md")
    
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
  
  func test__amazonURLRequest__setsHTTPHeader_Date() {
    // given
    let request = sut.amazonURLRequest(method: .get, path: "test")
    
    // when
    let headers = request.allHTTPHeaderFields!
    let dateHeader: String? = headers["Date"]
    
    // then
    XCTAssertNotNil(dateHeader, "Should have 'Date' header field")
    XCTAssertTrue(dateHeader!.hasSuffix("GMT"))
  }
  
  func test__amazonURLRequest__setsHTTPHeader_Authorization() {
    // given
    let request = sut.amazonURLRequest(method: .get, path: "test")
    
    // when
    let headers = request.allHTTPHeaderFields!
    let authHeader: String? = headers["Authorization"]
    
    // then
    XCTAssertNotNil(authHeader, "Should have 'Authorization' header field")
    XCTAssertTrue(authHeader!.hasPrefix("AWS \(accessKey):"), "Authorization header should begin with 'AWS [accessKey]'.")
  }
  
  func test__amazonURLRequest__givenACL__setsHTTPHeader_ACL() {
    // given
    let acl = PredefinedACL.publicReadWrite
    let request = sut.amazonURLRequest(method: .get, path: "test", acl: acl)
    
    // when
    let headers = request.allHTTPHeaderFields!
    let aclHeader: String? = headers["x-amz-acl"]
    
    // then
    XCTAssertNotNil(aclHeader, "Should have ACL header field")
  }
    
  func test__amazonURLRequest__givenMetaData__setsHTTPHeader_amz_meta() {
    // given
    let metaData = ["demo" : "foo"]
    let request = sut.amazonURLRequest(method: .head, path: "test", acl: nil, metaData: metaData)
    
    // when
    let headers = request.allHTTPHeaderFields!
    let metaDataHeader: String? = headers["x-amz-meta-demo"]
    
    // then
    XCTAssertEqual(metaDataHeader, "foo", "Meta data header field is not set correctly.")
  }
  
  func test__amazonURLRequest__givenCustomParameters_setsURLWithEndpointURL() {
    // given
    let path = "TestPath"
    let expectedEndpoint = "test.endpoint.com"
    let region = Region.custom(hostName: "", endpoint: expectedEndpoint)
    sut.region = region
    let expectedURL = URL(string: "https://\(expectedEndpoint)/\(bucket)/\(path)?custom-param=custom%20value%21%2F")!
    
    // when
    let request = sut.amazonURLRequest(method: .get, path: path, customParameters: ["custom-param" : "custom value!/"])
    
    // then
    XCTAssertEqual(request.url!, expectedURL)
  }
  
  func test__amazonURLRequest__givenCustomParameters_setsURLWithEndpointURL_ContinuationToken() {
    // given
    let path = "TestPath"
    let expectedEndpoint = "test.endpoint.com"
    let region = Region.custom(hostName: "", endpoint: expectedEndpoint)
    sut.region = region
    let expectedURL = URL(string: "https://\(expectedEndpoint)/\(bucket)/\(path)?continuation-token=1%2FkCRyYIP%2BApo2oop%2FGa8%2FnVMR6hC7pDH%2FlL6JJrSZ3blAYaZkzJY%2FRVMcJ")!
    
    // when
    let request = sut.amazonURLRequest(method: .get, path: path, customParameters: ["continuation-token" : "1/kCRyYIP+Apo2oop/Ga8/nVMR6hC7pDH/lL6JJrSZ3blAYaZkzJY/RVMcJ"])
    
    // then
    XCTAssertEqual(request.url!, expectedURL)
  }
  
  func test_amazonURLRequest__givenCustomHeaders() {
    // given
    let headers = ["header-demo" : "foo", "header-test" : "bar"]
    let request = sut.amazonURLRequest(method: .head, path: "test", customHeaders: headers)
    
    // when
    let httpHeaders = request.allHTTPHeaderFields!
    let header1: String? = httpHeaders["header-demo"]
    let header2: String? = httpHeaders["header-test"]
    
    // then
    XCTAssertEqual(header1, "foo", "Meta data header field is not set correctly.")
    XCTAssertEqual(header2, "bar", "Meta data header field is not set correctly.")
  }
  
  // MARK: Amazon Request URL Serialization - Tests
  
  func test__url_for_path__returnsURLWithEndpointURL() {
    // given
    let path = "TestPath"
    let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/\(path)")!
    
    // when
    let url = sut.url(withPath: path)
    
    // then
    XCTAssertEqual(url, expectedURL)
  }
  
  func test__url_for_path__givenCustomRegion_setsURLWithEndpointURL() {
    // given
    let path = "TestPath"
    let expectedEndpoint = "test.endpoint.com"
    let region = Region.custom(hostName: "", endpoint: expectedEndpoint)
    sut.region = region
    let expectedURL = URL(string: "https://\(expectedEndpoint)/\(bucket)/\(path)")!
    
    // when
    let url = sut.url(withPath: path)
    
    // then
    XCTAssertEqual(url, expectedURL)
  }
  
  func test__url_for_path__givenNoBucket__setsURLWithEndpointURL() {
    // given
    sut.bucket = nil
    
    let path = "TestPath"
    let expectedURL = URL(string: "https://\(region.endpoint)/\(path)")!
    
    // when
    let url = sut.url(withPath: path)
    
    // then
    XCTAssertEqual(url, expectedURL)
  }
  
  func test__url_for_path__givenNoPath() {
    // given
    sut.bucket = "test"
    
    let expectedURL = URL(string: "https://\(region.endpoint)/test")!
    
    // when
    let url = sut.url(withPath: nil)
    
    // then
    XCTAssertEqual(url, expectedURL)
  }
  
  func test__url_for_path__givenUseSSL_false_setsURLWithEndpointURL_usingHTTP() {
    // given
    sut.useSSL = false
    
    let path = "TestPath"
    let expectedURL = URL(string: "http://\(region.endpoint)/\(bucket)/\(path)")!
    
    // when
    let url = sut.url(withPath: path)
    
    // then
    XCTAssertEqual(url, expectedURL)
  }

  func test__url_for_path__givenCustomParameters_setsURLWithEndpointURL() {
    // given
    let path = "TestPath"
    let expectedEndpoint = "test.endpoint.com"
    let region = Region.custom(hostName: "", endpoint: expectedEndpoint)
    sut.region = region
    let expectedURL = URL(string: "https://\(expectedEndpoint)/\(bucket)/\(path)?custom-param=custom%20value%21%2F")!
    
    // when
    let url = sut.url(withPath: path, customParameters: ["custom-param" : "custom value!/"])
    
    // then
    XCTAssertEqual(url, expectedURL)
  }
  
  func test__url_for_path__givenCustomParameters_setsURLWithEndpointURL_ContinuationToken() {
    // given
    let path = "TestPath"
    let expectedEndpoint = "test.endpoint.com"
    let region = Region.custom(hostName: "", endpoint: expectedEndpoint)
    sut.region = region
    let expectedURL = URL(string: "https://\(expectedEndpoint)/\(bucket)/\(path)?continuation-token=1%2FkCRyYIP%2BApo2oop%2FGa8%2FnVMR6hC7pDH%2FlL6JJrSZ3blAYaZkzJY%2FRVMcJ")!
    
    // when
    let url = sut.url(withPath: path,
      customParameters: ["continuation-token" : "1/kCRyYIP+Apo2oop/Ga8/nVMR6hC7pDH/lL6JJrSZ3blAYaZkzJY/RVMcJ"])
    
    // then
    XCTAssertEqual(url, expectedURL)
  }
  
}

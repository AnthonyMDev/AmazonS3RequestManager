//
//  AmazonS3ResponseSerializationTests.swift
//  AmazonS3RequestManager
//
//  Created by Anthony Miller on 10/6/15.
//  Copyright © 2015 Anthony Miller. All rights reserved.
//

import Foundation
import XCTest
import Nimble

import Alamofire

@testable import AmazonS3RequestManager

class AmazonS3ResponseSerializationTests: XCTestCase {
  
  func test__s3DataResponseSerializer__givenPreviousError_returnsError() {
    // given
    let expectedError = NSError(domain: "test", code: 0, userInfo: nil)
    
    // when
    let result = Request.s3DataResponseSerializer().serializeResponse(nil, nil, nil, expectedError)
    
    // then
    expect(result.error).to(equal(expectedError))
  }
  
  func test__s3DataResponseSerializer__givenNoError_returnsSuccessWithData() {
    // given
    let data = NSData(base64EncodedString: "Test Data", options: .IgnoreUnknownCharacters)
    
    // when
    let result = Request.s3DataResponseSerializer().serializeResponse(nil, nil, data, nil)
    
    // then
    expect(result.value!).to(beIdenticalTo(data))
  }
  
  func test__s3DataResponseSerializer__givenEmptyStringResponse_returnsSuccessWithData() {
    // given
    let data = NSData(base64EncodedString: "", options: .IgnoreUnknownCharacters)
    
    // when
    let result = Request.s3DataResponseSerializer().serializeResponse(nil, nil, data, nil)
    
    // then
    expect(result.value!).to(beIdenticalTo(data))
  }
  
  func test__s3DataResponseSerializer__givenXMLErrorStringResponse_returnsError() {
    // given
    let expectedError = AmazonS3Error.NoSuchKey.error(failureReason: "The resource you requested does not exist")
    
    let xmlError = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
      "<Error>" +
        "<Code>NoSuchKey</Code>" +
        "<Message>The resource you requested does not exist</Message>" +
        "<Resource>/mybucket/myfoto.jpg</Resource>" +
        "<RequestId>4442587FB7D0A2F9</RequestId>" +
      "</Error>"
    
    let data = xmlError.dataUsingEncoding(NSUTF8StringEncoding)
    
    // when
    let result = Request.s3DataResponseSerializer().serializeResponse(nil, nil, data, nil)
    
    // then
    expect(result.error).to(equal(expectedError))
  }
  
  func test__s3DataResponseSerializer__givenXMLErrorStringResponseAndPreviousError_returnsXMLErrorError() {
    // given
    let previousError = NSError(domain: "test", code: 0, userInfo: nil)
    let expectedError = AmazonS3Error.NoSuchKey.error(failureReason: "The resource you requested does not exist")
    
    let xmlError = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
      "<Error>" +
      "<Code>NoSuchKey</Code>" +
      "<Message>The resource you requested does not exist</Message>" +
      "<Resource>/mybucket/myfoto.jpg</Resource>" +
      "<RequestId>4442587FB7D0A2F9</RequestId>" +
    "</Error>"
    
    let data = xmlError.dataUsingEncoding(NSUTF8StringEncoding)
    
    // when
    let result = Request.s3DataResponseSerializer().serializeResponse(nil, nil, data, previousError)
    
    // then
    expect(result.error).to(equal(expectedError))
  }
  
}

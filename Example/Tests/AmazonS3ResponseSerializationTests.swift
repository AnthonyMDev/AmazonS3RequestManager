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
import SWXMLHash

@testable import AmazonS3RequestManager

class AmazonS3ResponseSerializationTests: XCTestCase {
    
    /*
     *  MARK: - Utilities
     */
    
    class MockResponseObject: ResponseObjectSerializable {
        
        required init?(response: NSHTTPURLResponse, representation: XMLIndexer) {
            if representation["fail"].element !=  nil { return nil }
        }
        
    }
    
    /*
     *  MARK: XMLResponseSerializer
     */
    
    func test__XMLResponseSerializer__givenNilData_returnsFailure() {
        // when
        let result = Request.XMLResponseSerializer().serializeResponse(nil, nil, nil, nil)
        
        // then
        expect(result.error?.code).to(equal(Error.Code.DataSerializationFailed.rawValue))
    }
    
    func test__XMLResponseSerializer__givenXMLString_returnsXMLIndexer() {
        // given
        let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
            "<XMLData>" +
            "<XMLElement>test</XMLElement>" +
        "</XMLData>"
        let data = xml.dataUsingEncoding(NSUTF8StringEncoding)
        
        // when
        let result = Request.XMLResponseSerializer().serializeResponse(nil, nil, data, nil)
        let testContent = result.value!["XMLData"]["XMLElement"].element?.text
        
        // then
        expect(result.error).to(beNil())
        expect(testContent).to(equal("test"))
    }
    
    /*
     *  MARK: - S3DataResponseSerializer
     */
    
    func test__s3DataResponseSerializer__givenPreviousError_returnsError() {
        // given
        let data = NSData(base64EncodedString: "", options: .IgnoreUnknownCharacters)
        let expectedError = NSError(domain: "test", code: 0, userInfo: nil)
        
        // when
        let result = Request.s3DataResponseSerializer().serializeResponse(nil, nil, data, expectedError)
        
        // then
        expect(result.error).to(equal(expectedError))
    }
    
    func test__s3DataResponseSerializer__givenNoData_returnsError() {
        // given
        let failureReason = "The response did not include any data."
        let userInfo: [NSObject: AnyObject] = [NSLocalizedFailureReasonErrorKey: failureReason]
        let expectedError = NSError(domain: Request.S3ErrorDomain, code: Error.Code.DataSerializationFailed.rawValue, userInfo: userInfo)
        
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
    
    /*
     *  MARK: - S3ObjectResponseSerializer
     */
    
    func test__s3ObjectResponseSerializer__givenPreviousError_returnsError() {
        // given
        let expectedError = NSError(domain: "test", code: 0, userInfo: nil)
        
        let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        let data = xml.dataUsingEncoding(NSUTF8StringEncoding)
        
        // when
        let result: Result<MockResponseObject, NSError> = Request
            .s3ObjectResponseSerializer().serializeResponse(nil, NSHTTPURLResponse(), data, expectedError)
        
        // then
        expect(result.error).to(equal(expectedError))
    }
    
    func test__s3ObjectResponseSerializer__givenXMLRepresentation_responseObjectSerializedSuccessfully__returnsResponseObject() {
        // given
        let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        let data = xml.dataUsingEncoding(NSUTF8StringEncoding)
        
        // when
        let result: Result<MockResponseObject, NSError> = Request
            .s3ObjectResponseSerializer().serializeResponse(nil, NSHTTPURLResponse(), data, nil)
        
        // then
        expect(result.value).toNot(beNil())
    }
    
    func test__s3ObjectResponseSerializer__givenXMLRepresentation_responseObjectFailsToSerialize__returnsError() {
        // given
        let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><fail>"
        let data = xml.dataUsingEncoding(NSUTF8StringEncoding)
        
        // when
        let result: Result<MockResponseObject, NSError> = Request
            .s3ObjectResponseSerializer().serializeResponse(nil, NSHTTPURLResponse(), data, nil)
        
        // then
        expect(result.error?.code).to(equal(Error.Code.DataSerializationFailed.rawValue))
    }
    
    func test__s3ObjectResponseSerializer__givenXMLErrorStringResponse_returnsError() {
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
        let result: Result<MockResponseObject, NSError> = Request
            .s3ObjectResponseSerializer().serializeResponse(nil, nil, data, nil)
        
        // then
        expect(result.error).to(equal(expectedError))
    }
    
    func test__s3ObjectResponseSerializer__givenXMLErrorStringResponseAndPreviousError_returnsXMLErrorError() {
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
        let result: Result<MockResponseObject, NSError> = Request
            .s3ObjectResponseSerializer().serializeResponse(nil, nil, data, previousError)
        
        // then
        expect(result.error).to(equal(expectedError))
    }
    
    /*
     *  MARK: - S3MetaDataResponseSerializer
     */
    
    func test__s3MetaDataResponseSerializer__givenPreviousError_returnsError() {
        // given
        let expectedError = NSError(domain: "test", code: 0, userInfo: nil)
        
        // when
        let result = Request.s3MetaDataResponseSerializer().serializeResponse(nil, nil, nil, expectedError)
        
        // then
        expect(result.error).to(equal(expectedError))
    }
    
    func test__s3MetaDataResponseSerializer__givenNoError_noResponse_returnsError() {
        // given
        let failureReason = "No response data was found."
        let userInfo: [NSObject: AnyObject] = [NSLocalizedFailureReasonErrorKey: failureReason]
        let expectedError = NSError(domain: Request.S3ErrorDomain, code: Error.Code.DataSerializationFailed.rawValue, userInfo: userInfo)
        
        // when
        let result = Request.s3MetaDataResponseSerializer().serializeResponse(nil, nil, nil, nil)
        
        // then
        expect(result.error).to(equal(expectedError))
    }
    
    func test__s3MetaDataResponseSerializer__givenResponse_returnsSuccessWithMetaData() {
        // given
        let headers = ["x-amz-meta-test1" : "foo", "x-amz-meta-test2" : "bar"]
        let response = NSHTTPURLResponse(URL: NSURL(), statusCode: 200, HTTPVersion: nil, headerFields: headers)
        
        // when
        let result = Request.s3MetaDataResponseSerializer().serializeResponse(nil, response, nil, nil)
        let metaDataObject = result.value
        
        // then
        expect(metaDataObject?.metaData["test1"]).to(equal("foo"))
        expect(metaDataObject?.metaData["test2"]).to(equal("bar"))
    }
    
    func test__s3MetaDataResponseSerializer__givenResponseWithNoHeaders_returnsError() {
        // given
        let failureReason = "No meta data was found."
        
        let userInfo: [NSObject: AnyObject] = [NSLocalizedFailureReasonErrorKey: failureReason]
        let expectedError = NSError(domain: Request.S3ErrorDomain, code: Error.Code.DataSerializationFailed.rawValue, userInfo: userInfo)
        let response = NSHTTPURLResponse(URL: NSURL(), statusCode: 200, HTTPVersion: nil, headerFields: nil)
        
        // whenS
        let result = Request.s3MetaDataResponseSerializer().serializeResponse(nil, response, nil, nil)
        
        // then
        expect(result.error).to(equal(expectedError))
    }
    
}

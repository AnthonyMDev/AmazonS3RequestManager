//
//  AmazonS3RequestManagerTests.swift
//  AmazonS3RequestManagerTests
//
//  Created by Anthony Miller on 3/3/15.
//  Copyright (c) 2015 Anthony Miller. All rights reserved.
//

import XCTest
import Nimble
import Nocilla

import Alamofire
@testable import AmazonS3RequestManager

class AmazonS3RequestManagerTests: XCTestCase {
    
    var sut: AmazonS3RequestManager!
    
    let accessKey = "key"
    let secret = "secret"
    let bucket = "bucket"
    let region = Region.USWest1
    
    let mockURL = URL(string: "http://www.test.com")!
    let mockDestination: DownloadRequest.DownloadFileDestination = { _, _ in return(URL(string: "http://www.test.com")!, []) }
    
    override func setUp() {
        super.setUp()
        
        sut = AmazonS3RequestManager(bucket: bucket,
            region: region,
            accessKey: accessKey,
            secret: secret)
        
        sut.requestManager.startRequestsImmediately = false
    }
    
    /*
    *  MARK: - Initialization - Tests
    */
    
    func test__inits__withConfiguredRequestSerializer() {
        expect(self.sut.requestSerializer.accessKey).to(equal(self.accessKey))
        expect(self.sut.requestSerializer.secret).to(equal(self.secret))
        expect(self.sut.requestSerializer.bucket).to(equal(self.bucket))
        expect(self.sut.requestSerializer.region.hostName).to(equal(self.region.hostName))
    }
    
    /*
    *  MARK: - GET Object Request - Tests
    */
    
    func test__getObject__setsHTTPMethod() {
        // given      
        let expected = "GET"
        
        // when
        let request = sut.get(at: "test")
        
        // then
        XCTAssertEqual(request.request!.httpMethod!, expected)
    }
    
    func test__getObject__setsURLWithEndpoint() {
        // given
        let path = "TestPath"
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/TestPath")!
        
        // when
        let request = sut.get(at: path)
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    /*
    *  MARK: - Download Object Request - Tests
    */
    
    func test__downloadObject_path_saveToURL_returnsDownloadRequest() {
        // when
        let request = sut.download(at: "test", to: mockDestination)
        
        // then
        XCTAssertTrue(request.task!.isKind(of: URLSessionDownloadTask.self))
    }
    
    func test__downloadObject_path_saveToURL_setsHTTPMethod() {
        // given
        let expected = "GET"
        
        // when
        let request = sut.download(at: "test", to: mockDestination)
        
        // then
        XCTAssertEqual(request.request!.httpMethod!, expected)
    }
    
    func test__downloadObject_path_saveToURL_setsURLWithEndpoint() {
        // given
        let path = "TestPath"
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/TestPath")!
        
        // when
        let request = sut.download(at: path, to: mockDestination)
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    /*
    *  MARK: - GET Bucket Object List Request - Tests
    */
    
    func test__listBucketObjects__setsHTTPMethod() {
        // given
        let expected = "GET"
        
        // when
        let request = sut.listBucketObjects()
        
        // then
        XCTAssertEqual(request.request!.httpMethod!, expected)
    }
    
    func test__listBucketObjects__setsURL() {
        // given
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)?list-type=2")!
        
        // when
        let request = sut.listBucketObjects()
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    func test__listBucketObjectsWithCustomParameters__setsURL() {
        // given
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)?list-type=2&max-keys=100&prefix=TestPath")!
        
        // when
        let request = sut.listBucketObjects(maxKeys: 100, prefix: "TestPath")
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    /*
    *  MARK: - Upload Object Request - Tests
    */
    
    func test__upload_fileURL_destinationPath__returnsUploadRequest() {
        // when
        let request = sut.upload(from: mockURL, to: "path")
        
        // then
        XCTAssertTrue(request.task!.isKind(of: URLSessionUploadTask.self))
    }
    
    func test__upload_fileURL_destinationPath_setsHTTPMethod() {
        // given
        let expected = "PUT"
        
        // when
        let request = sut.upload(from: mockURL, to: "path")
        
        // then
        XCTAssertEqual(request.request!.httpMethod!, expected)
    }
    
    func test__upload_fileURL_destinationPath_setsURLWithEndpoint() {
        // given
        let path = "TestPath"
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/TestPath")!
        
        // when
        let request = sut.upload(from: mockURL, to: path)
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    func test__upload_fileURL_destinationPath__givenACL_setsHTTPHeader_ACL() {
        // given
        let acl = PredefinedACL.publicReadWrite
        let path = "TestPath"
        
        let request = sut.upload(from: mockURL, to: path, acl: acl)
        
        // when
        let headers = request.request!.allHTTPHeaderFields!
        let aclHeader: String? = headers["x-amz-acl"]
        
        // then
        XCTAssertNotNil(aclHeader, "Should have ACL header field")
    }
    
    func test__upload_data_destinationPath__returnsUploadRequest() {
        // when
        let request = sut.upload(Data(), to: "path")
        
        // then
        XCTAssertTrue(request.task!.isKind(of: URLSessionUploadTask.self))
    }
    
    func test__upload_data_destinationPath__setsHTTPMethod() {
        // given
        let expected = "PUT"
        
        // when
        let request = sut.upload(Data(), to: "path")
        
        // then
        XCTAssertEqual(request.request!.httpMethod!, expected)
    }
    
    func test__upload_data_destinationPath__setsURLWithEndpoint() {
        // given
        let path = "TestPath"
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/TestPath")!
        
        // when
        let request = sut.upload(Data(), to: path)
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    func test__upload_data_destinationPath__givenACL_setsHTTPHeader_ACL() {
        // given
        let acl = PredefinedACL.publicReadWrite
        let path = "TestPath"
        
        let request = sut.upload(Data(), to: path, acl: acl)
        
        // when
        let headers = request.request!.allHTTPHeaderFields!
        let aclHeader: String? = headers["x-amz-acl"]
        
        // then
        XCTAssertNotNil(aclHeader, "Should have ACL header field")
    }
    
     /*
     *  MARK: - COPY Request - Tests
     */
    
    func test__copy_setsHTTPMethod() {
        // given
        let expected = "PUT"
        
        // when
        let request = sut.copy(from: "test", to: "demo")
        
        // then
        XCTAssertEqual(request.request!.httpMethod!, expected)
    }
    
    func test__copy_givenDestinationPath_setsHTTPHeader_amz_copy() {
        // given
        let sourcePath = "TestSourcePath"
        let targetPath = "TestTargetPath"
        let expectedCompleteSourcePath = "/" + bucket + "/" + sourcePath
        
        let request = sut.copy(from: sourcePath, to: targetPath)
        
        // when
        let headers = request.request!.allHTTPHeaderFields!
        let copyHeader: String = headers["x-amz-copy-source"]!
        
        // then
        XCTAssertEqual(copyHeader, expectedCompleteSourcePath, "AMZ copy header is not set correctly")
    }
    
    func test__copy_fileURL_destinationPath_setsURLWithEndpoint() {
        // given
        let path = "TestPath"
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/TestPath")!
        
        // when
        let request = sut.copy(from: "sourcePath", to: path)
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    /*
    *  MARK: - DELETE Request - Tests
    */
    
    func test__delete_setsHTTPMethod() {
        // given
        let expected = "DELETE"
        
        // when
        let request = sut.delete(at: "test")
        
        // then
        XCTAssertEqual(request.request!.httpMethod!, expected)
    }
    
    func test__delete_setsURLWithEndpoint() {
        // given
        let path = "TestPath"
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/TestPath")!
        
        // when
        let request = sut.delete(at: path)
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    /*
    *  MARK: - Get Metadata Request - Tests
    */
    
    func test__getMetaData_setsHTTPMethod() {
        // given
        let expected = "HEAD"
        
        // when
        let request = sut.getMetaData(forObjectAt: "test")
        
        // then
        XCTAssertEqual(request.request!.httpMethod!, expected)
    }
    
    func test__getMetaData__setsURLWithEndpoint() {
        // given
        let path = "TestPath"
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/TestPath")!
        
        // when
        let request = sut.getMetaData(forObjectAt: path)
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    /*
    *  MARK: - ACL Request - Tests
    */
    
    func test__getBucketACL__setsHTTPMethod() {
        // given
        let expected = "GET"
        
        // when
        let request = sut.getBucketACL()
        
        // then
        XCTAssertEqual(request.request!.httpMethod!, expected)
    }
    
    func test__getObject__setsURL_withACLSubresource() {
        // given
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/?acl")!
        
        // when
        let request = sut.getBucketACL()
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    func test__setBucketACL__setsHTTPMethod() {
        // given
        let expected = "PUT"
        
        let acl = PredefinedACL.publicReadWrite
        
        // when
        let request = sut.setBucketACL(acl)
        
        // then
        XCTAssertEqual(request.request!.httpMethod!, expected)
    }
    
    func test__setBucketACL_setsURLWithEndpoint() {
        // given
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/?acl")!
        
        let acl = PredefinedACL.publicReadWrite
        
        // when
        let request = sut.setBucketACL(acl)
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    func test__setBucketACL_setsHTTPHeader_ACL() {
        // given
        let acl = PredefinedACL.publicReadWrite
        
        // when
        let request = sut.setBucketACL(acl)
        
        let headers = request.request!.allHTTPHeaderFields!
        let aclHeader: String? = headers["x-amz-acl"]
        
        // then
        XCTAssertNotNil(aclHeader, "Should have ACL header field")
    }
    
    func test__getACL_forObjectAt__setsHTTPMethod() {
        // given
        let expected = "GET"
        
        // when
        let request = sut.getACL(forObjectAt: "test")
        
        // then
        XCTAssertEqual(request.request!.httpMethod!, expected)
    }
    
    func test__getACL_forObjectAt__setsURL_withACLSubresource() {
        // given
        let path = "TestPath"
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/\(path)?acl")!
        
        // when
        let request = sut.getACL(forObjectAt: path)
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    func test__setACL_forObjectAt__setsHTTPMethod() {
        // given
        let expected = "PUT"
        
        let path = "TestPath"
        let acl = PredefinedACL.publicReadWrite
        
        // when
        let request = sut.setACL(acl, forObjectAt: path)
        
        // then
        XCTAssertEqual(request.request!.httpMethod!, expected)
    }
    
    func test__setACL_forObjectAt__setsURLWithEndpoint() {
        // given
        let path = "TestPath"
        let acl = PredefinedACL.publicReadWrite
        
        let expectedURL = URL(string: "https://\(region.endpoint)/\(bucket)/\(path)?acl")!
        
        // when
        let request = sut.setACL(acl, forObjectAt: path)
        
        // then
        XCTAssertEqual(request.request!.url!, expectedURL)
    }
    
    func test__setACL_forObjectAtPath__setsHTTPHeader_ACL() {
        // given
        let acl = PredefinedACL.publicReadWrite
        let path = "TestPath"
        
        // when
        let request = sut.setACL(acl, forObjectAt: path)
        
        let headers = request.request!.allHTTPHeaderFields!
        let aclHeader: String? = headers["x-amz-acl"]
        
        // then
        XCTAssertNotNil(aclHeader, "Should have ACL header field")
    }
    
}

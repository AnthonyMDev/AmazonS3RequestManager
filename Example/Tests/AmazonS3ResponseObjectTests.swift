//
//  AmazonS3ResponseObjectTests.swift
//  AmazonS3RequestManager
//
//  Created by Sebastian Hunkeler on 19/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import Nimble
import Alamofire

@testable import AmazonS3RequestManager

class AmazonS3ResponseObjectTests: XCTestCase {
    
    let mockURL = URL(string: "http://www.test.com")!
    
    func test__S3ObjectMetaData_givenMetaData_setsMetaData() {
        // given
        let headers = ["x-amz-meta-test1" : "foo", "x-amz-meta-test2" : "bar"]
        let response = HTTPURLResponse(url: mockURL, statusCode: 200, httpVersion: nil, headerFields: headers)
        
        // when
        let metaDataResult = S3ObjectMetaData(response:response!)!
        
        // then
        expect(metaDataResult.metaData["test1"]).to(equal("foo"))
        expect(metaDataResult.metaData["test2"]).to(equal("bar"))
    }
    
    func test__S3ObjectMetaData_givenNoHeaders_returnsNil() {
        // given
        let response = HTTPURLResponse(url: mockURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // when
        let metaDataResult = S3ObjectMetaData(response:response!)
        
        // then
        expect(metaDataResult).to(beNil())
    }
    
    func test__responseS3Object_givenXMLString_returnsS3ListBucketResult() {
        // given
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
        let expectedModifiedDate = dateFormatter.date(from: "2016-03-03 14:54:27.000Z")
        
        let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
            "<ListBucketResult xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\">" +
            "<IsTruncated>true</IsTruncated>" +
            "<MaxKeys>3</MaxKeys>" +
            "<Delimiter />" +
            "<Marker />" +
            "<Prefix />" +
            "<Name>TESTBUCKET1</Name>" +
            "<Contents>" +
            "<Key>demo.txt</Key>" +
            "<LastModified>2016-03-03T14:54:27.000Z</LastModified>" +
            "<ETag>\"2016-03-03 14:54:27.043:75b650fa317e55090741576852a79562\"</ETag>" +
            "<Size>6</Size>" +
            "<StorageClass>STANDARD</StorageClass>" +
            "<Owner>" +
            "<ID>61646d696e00000000</ID>" +
            "<DisplayName>admin</DisplayName>" +
            "</Owner>" +
            "</Contents>" +
            "<Contents>" +
            "<Key>test.rtf</Key>" +
            "<LastModified>2016-02-23T15:38:06.000Z</LastModified>" +
            "<ETag>\"2016-02-23 15:38:06.741:01250c473283ed48e8429338500a97e1\"</ETag>" +
            "<Size>178</Size>" +
            "<StorageClass>STANDARD</StorageClass>" +
            "<Owner>" +
            "<ID>61646d696e000000000</ID>" +
            "<DisplayName>admin</DisplayName>" +
            "</Owner>" +
            "</Contents>" +
        "</ListBucketResult>"
        let data = xml.data(using: String.Encoding.utf8)
        
        // when
        let result = DataRequest.XMLResponseSerializer().serializeResponse(nil, nil, data, nil)
        let xmlIndexer = result.value!
        let bucketContents = S3BucketObjectList(response:HTTPURLResponse(), representation:xmlIndexer)!
        let s3File = bucketContents.files.first!
        
        // then
        expect(bucketContents.files).to(haveCount(2))
        expect(bucketContents.bucket).to(equal("TESTBUCKET1"))
        expect(bucketContents.truncated).to(equal(true))
        expect(bucketContents.maxKeys).to(equal(3))
        
        expect(s3File.path).to(equal("demo.txt"))
        expect(s3File.lastModifiedDate).to(equal(expectedModifiedDate))
        expect(s3File.size).to(equal(6))
        expect(s3File.entityTag).to(equal("\"2016-03-03 14:54:27.043:75b650fa317e55090741576852a79562\""))
        expect(s3File.storageClass).to(equal(StorageClass.standard))
        expect(s3File.owner!.id).to(equal("61646d696e00000000"))
        expect(s3File.owner!.name).to(equal("admin"))
    }

}

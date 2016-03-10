//
//  AWSSignatureV4TestCase.swift
//  AmazonS3RequestManager
//
//  Created by Anthony Miller on 3/7/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

import Nimble

@testable import AmazonS3RequestManager

class AWSSignatureV4TestCase: XCTestCase {
    
    let accessKey = "AKIDEXAMPLE"
    let secret = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
    let region = AmazonS3Region.USStandard
    let service = "service"
    
    let testNames = [
        "get-header-key-duplicate", "get-header-value-order",
        "get-header-value-trim", "get-space", "get-unreserved", "get-utf8", "get-vanilla",
        "get-vanilla-empty-query-key", "get-vanilla-query", "get-vanilla-query-order-key",
        "get-vanilla-query-order-value", "get-vanilla-query-unreserved", "get-vanilla-utf8-query",
        "post-header-key-case", "post-header-key-sort", "post-header-value-case", "post-vanilla",
        "post-vanilla-empty-query-value", "post-vanilla-query",
        "post-vanilla-query-space", "post-x-www-form-urlencoded", "post-x-www-form-urlencoded-parameters"]
    
    // Instance properties
    
    private let bundle = NSBundle(forClass: AWSSignatureV4TestCase.self)
    
    private func actualRequestInfo(testName: String) -> String {
        let path = bundle.pathForResource(testName, ofType: "req")!
        return try! NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
    }
    
    private func expectedCanonicalRequest(testName: String) -> String {
        let path = bundle.pathForResource(testName, ofType: "creq")!
        return try! NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
    }
    
    private func expectedStringToSign(testName: String) -> String {
        let path = bundle.pathForResource(testName, ofType: "sts")!
        return try! NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
    }
    
    private func expectedAuthorizationHeaderString(testName: String) -> String {
        let path = bundle.pathForResource(testName, ofType: "authz")!
        return try! NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
    }
    
    /*
    *  MARK: - Tests
    */
    
    func test_V4Signature_canonicalRequest() {
        for test in testNames {
            // given
            let expected = self.expectedCanonicalRequest(test)
            let request = AWSTestRequestData(requestInfo: actualRequestInfo(test)).urlRequest()
            
            // when
            let actual = AWSV4SignatureCalculator.canonicalRequest(request)
            
            // then
            expect(actual).to(equal(expected), description: "Failed \(test)")
        }
    }
    
    func test_V4Signature_stringToSign() {
        for test in testNames {
            // given
            let expected = self.expectedStringToSign(test)
            let request = AWSTestRequestData(requestInfo: actualRequestInfo(test)).urlRequest()
            
            // when
            let actual = AWSV4SignatureCalculator.stringToSign(request,
                region: region,
                service: service,
                canonicalRequest: AWSV4SignatureCalculator.canonicalRequest(request))
            
            // then
            expect(actual).to(equal(expected), description: "Failed \(test)")
        }
    }
    
    func test_V4Signature_authorizationHeader() {
        // given
        for test in testNames {
            let expected = self.expectedAuthorizationHeaderString(test)
            let request = AWSTestRequestData(requestInfo: actualRequestInfo(test)).urlRequest()
            
            // when
            let actual = AWSV4SignatureCalculator.V4AuthorizationHeader(request,
                accessKey: accessKey,
                secret: secret,
                region: region,
                service: service)
            
            // then
            expect(actual).to(equal(expected), description: "Failed \(test)")
        }
    }
    
}

private struct AWSTestRequestData {
    
    var method: String
    
    var path: String
    
    var contentType: String?
    
    var host: String
    
    var timestamp: String
    
    var headers: [(key: String, value: String)] = []
    
    var body: String?
    
    init(requestInfo: String) {
        let lines = requestInfo.componentsSeparatedByString("\n")
        let firstLineInfo = lines.first!.componentsSeparatedByString(" ")
        
        method = firstLineInfo[0]
        path = firstLineInfo[1]
        
        contentType = lines.filter { $0.hasPrefix("Content-Type:") }.first?
            .stringByReplacingOccurrencesOfString("Content-Type:", withString: "")
        
        host = lines.filter { $0.hasPrefix("Host:") }.first!
            .stringByReplacingOccurrencesOfString("Host:", withString: "")
        
        timestamp = lines.filter { $0.hasPrefix("X-Amz-Date:") }.first!
            .stringByReplacingOccurrencesOfString("X-Amz-Date:", withString: "")
        
        let pattern = "(My-Header[[:digit:]]+):([\\s\\S]*?(?=\n(My-Header[[:digit:]]+|X-Amz-Date)+:))"
        let headerRegex = try! NSRegularExpression(pattern: pattern,
            options: NSRegularExpressionOptions.init(rawValue: 0))
        
        headerRegex.enumerateMatchesInString(requestInfo,
            options: NSMatchingOptions(rawValue: 0),
            range: NSMakeRange(0, requestInfo.characters.count),
            usingBlock: { (match, flags, bool) -> Void in
                if let match = match,
                    let headerKeyRange = self.rangeFromNSRange(match.rangeAtIndex(1), forString: requestInfo),
                    let headerValueRange = self.rangeFromNSRange(match.rangeAtIndex(2), forString: requestInfo) {
                        let headerKey = requestInfo.substringWithRange(headerKeyRange)
                        let headerValue = requestInfo.substringWithRange(headerValueRange)
                        self.headers.append((key: headerKey, value: headerValue))
                }
        })
        
        if lines[lines.count - 2].isEmpty {
            body = lines.last
        }
        
    }
    
    private func rangeFromNSRange(nsRange: NSRange, forString str: String) -> Range<String.Index>? {
        let fromUTF16 = str.utf16.startIndex.advancedBy(nsRange.location, limit: str.utf16.endIndex)
        let toUTF16 = fromUTF16.advancedBy(nsRange.length, limit: str.utf16.endIndex)
        
        
        if let from = String.Index(fromUTF16, within: str),
            let to = String.Index(toUTF16, within: str) {
                return from ..< to
        }
        
        return nil
    }
    
    func urlRequest() -> NSURLRequest {
        let url = NSURL(scheme: "http", host: host, path: path)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.HTTPBody = body?.dataUsingEncoding(NSASCIIStringEncoding)
        request.setValue(host, forHTTPHeaderField: "Host")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(timestamp, forHTTPHeaderField: "X-Amz-Date")
        
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        return request
    }
    
    
}
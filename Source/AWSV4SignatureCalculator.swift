//
//  AWSV4SignatureCalculator.swift
//  Pods
//
//  Created by Anthony Miller on 3/2/16.
//
//

import Foundation

class AWSV4SignatureCalculator {
    
    class func V4Signature(request: NSURLRequest, accessKey: String, secret: String, region: AmazonS3Region) -> String {
        let canonicalRequest = self.canonicalRequest(request)!
        
        return ""
    }

    private class func canonicalRequest(request: NSURLRequest) -> String? {
        guard let URL = request.URL else { return nil }
        
        let HTTPMethod = request.HTTPMethod ?? ""
        let path = URL.path ?? "/"
        let query = canonicalQueryString(URL)
        let headers = canonicalHeaders(request)
        let headersList = canonicalHeaderList(request)
        let bodyHash = canonicalContentHash(request)
        
        let canonicalRequest = HTTPMethod + "\n" +
        path + "\n" +
        query + "\n" +
        headers + "\n" +
        headersList + "\n" +
        bodyHash
        
        return canonicalRequest
    }
    
    private class func canonicalQueryString(URL: NSURL) -> String {
        guard let queryStrings = URL.query?.componentsSeparatedByString("&") else { return "" }
        
        var items = queryStrings.flatMap { item -> (String, String?)? in
            let components = item.componentsSeparatedByString("=")
            guard let key = components.first else { return nil }
            return (key, components.last)
        }
        items.sortInPlace { return $0.0.lowercaseString < $1.0.lowercaseString }
        
        return items.map { (key, value) -> String in
            return key + "=" + (value ?? "")
        }.joinWithSeparator("&")
    }
    
    private class func canonicalHeaders(request: NSURLRequest) -> String {
        var headers = [String: String]()
        
        headers["host"] = request.URL!.host
        
        if let contentType = request
            .valueForHTTPHeaderField("Content-Type")?
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) {
                headers["content-type"] = contentType
        }
        
        request.allHTTPHeaderFields?.forEach {
            if $0.0.hasPrefix("x-amz-") {
                headers[$0.0.lowercaseString] = $0.1.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
        }
        
        return headers
            .sort { return $0.0 < $1.0 }
            .map { return $0.0 + ":" + $0.1 }
            .joinWithSeparator("\n") + "\n"
    }
    
    private class func canonicalHeaderList(request: NSURLRequest) -> String {
        var headers = ["host"]
        
        if request.valueForHTTPHeaderField("Content-Type") != nil {
            headers.append("content-type")
        }
        
        request.allHTTPHeaderFields?.forEach {
            if $0.0.hasPrefix("x-amz-") {
                headers.append($0.0.lowercaseString)
            }
        }
        
        return headers
            .sort { return $0 < $1 }
            .joinWithSeparator(";")
    }
    
    private class func canonicalContentHash(request: NSURLRequest) -> String {
        var contentString = ""
        
        if let bodyData = request.HTTPBody,
         encodedBody = String(data: AmazonS3SignatureHelpers.hash(bodyData), encoding: NSASCIIStringEncoding) {
            contentString = encodedBody
        }
        
        return AmazonS3SignatureHelpers.hexEncode(contentString)
    }
    
    private class func stringToSign(
}
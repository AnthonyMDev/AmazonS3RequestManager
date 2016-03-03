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
        return ""
    }

    private class func canonicalRequest(request: NSURLRequest) -> String? {
        guard let URL = request.URL else { return nil }
        
        let HTTPMethod = request.HTTPMethod ?? ""
        let path = URL.path ?? "/"
        let query = canonicalRequest(URL)
        
        var canonicalRequest = HTTPMethod + "\n" +
        path + "\n" +
        query + "\n" +
        
        return ""
    }
    
    private func canonicalQueryString(URL: NSURL) -> String {
        guard let queryStrings = URL.query?.componentsSeparatedByString("&") else { return "" }
        
        var items = queryStrings.flatMap { item -> (String, String?)? in
            let components = item.componentsSeparatedByString("=")
            guard let key = components.first else { return nil }
            return (key, components.last)
        }
        items.sortInPlace { return $0.0 < $1.0 }
        
        return items.map { (key, value) -> String in
            return key + "=" + (value ?? "")
        }.joinWithSeparator("&")
    }
    
}
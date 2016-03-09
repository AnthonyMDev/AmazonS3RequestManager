//
//  AWSV4SignatureCalculator.swift
//  Pods
//
//  Created by Anthony Miller on 3/2/16.
//
//

import Foundation

/**
 This class calculates a signature and creates an `Authorization` header for a request to the AWS S3 REST API using
 the V4 signature.
 
 - note: See `http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html` for more information.
 */
class AWSV4SignatureCalculator {
    
    private struct Constants {
        static let EmptyStringASCIIData = "".dataUsingEncoding(NSASCIIStringEncoding)!
    }
    
    /**
     Calculates the hash of the request's `HTTPBody`.
     
     - note: This hash should be set as the value for the `x-amz-content-sha256` HTTP Header Field.
     
     - parameter request: The request to calculate the payload hash for.
     
     - returns: The hashed string of the request's payload.
     */
    class func payloadHash(request request: NSURLRequest) -> String {
        let contentBody = request.HTTPBody ?? Constants.EmptyStringASCIIData
        
        return payloadHash(HTTPBody: contentBody)
    }
    
    private class func payloadHash(HTTPBody body: NSData) -> String {
        let encodedBody = String(data: AmazonS3SignatureHelpers.hash(body), encoding: NSASCIIStringEncoding)
        
        return AmazonS3SignatureHelpers.hexEncode(encodedBody)
    }
    
    /**
     Calculates an `Authorization` header for a request to the AWS S3 REST API using the V4 signature.
     
     - parameter request:   The `NSURLRequest` to calculate the `Authorization` header for.
     - parameter accessKey: The Amazon S3 Access Key ID to sign the request with.
     - parameter secret:    The Amazon S3 Secret to sign the request with.
     - parameter region:    The Amazon S3 region for the request.
     - parameter service:   The AWS service to sign the request for. Defaults to `s3`.
     
     - note: Currently, only the Amazon S3 `service` is supported.
     
     - returns: The `String` to set for the `Authorization` header on the given request.
     */
    class func V4AuthorizationHeader(request: NSURLRequest,
        accessKey: String,
        secret: String,
        region: AmazonS3Region,
        service: String = "s3") -> String {
            let credentialScope = self.credentialScope(request,
                region: region,
                service: service)
            let stringToSign = self.stringToSign(request,
                region: region,
                service: service,
                canonicalRequest: canonicalRequest(request))
            let signedHeaders = canonicalHeaderList(request)
            let signature = self.signature(request, stringToSign: stringToSign, secret: secret, region: region, service: service)
            
            return "AWS4-HMAC-SHA256" + " " +
                "Credential=\(accessKey)/\(credentialScope)" + ", " +
                "SignedHeaders=\(signedHeaders)" + ", " +
                "Signature=\(signature)"
    }
    
    /*
    *  MARK: Canonical Request
    */
    
    class func canonicalRequest(request: NSURLRequest) -> String {
        let HTTPMethod = request.HTTPMethod ?? ""
        let path = AmazonS3SignatureHelpers.AmazonS3URLPathForURL(request.URL!)
        let query = canonicalQueryString(request.URL!)
        let headers = canonicalHeaders(request)
        let headersList = canonicalHeaderList(request)
        let contentHash = self.canonicalContentHash(request)
        
        let canonicalRequest = HTTPMethod + "\n" +
            path + "\n" +
            query + "\n" +
            headers + "\n" +
            headersList + "\n" +
            contentHash
        
        return canonicalRequest
    }
    
    private class func canonicalQueryString(URL: NSURL) -> String {
        guard let query = URL.query else { return "" }
        let queryStrings = query.componentsSeparatedByString("&")
        
        var items = queryStrings.flatMap { item -> (String, String?)? in
            let components = item.componentsSeparatedByString("=")
            guard let key = components.first else { return nil }
            let value: String? = components.count > 1 ? components[1] : nil
            return (key, value)
        }
        items.sortInPlace {
            if $0.0 == $1.0 {
                return $0.1 < $1.1
            } else {
                return $0.0 < $1.0
            }
        }
        
        return items.map { (key, value) -> String in
            return (key as NSString).AMS3_stringWithURLEncodingQuery() + "=" +
                ((value ?? "") as NSString).AMS3_stringWithURLEncodingQuery()
            
            }.joinWithSeparator("&")
    }
    
    private class func canonicalHeaders(request: NSURLRequest) -> String {
        var headers = [String: String]()
    
        request.allHTTPHeaderFields?.forEach {
            let parts = $0.1.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) as NSArray
            let nonWhitespace = parts.filteredArrayUsingPredicate(NSPredicate(format:"SELF != ''")) as! [String]
            
            headers[$0.0.lowercaseString] = nonWhitespace.joinWithSeparator(" ")
        }
        
        return headers
            .sort { return $0.0 < $1.0 }
            .map { return $0.0 + ":" + $0.1 }
            .joinWithSeparator("\n") + "\n"
    }
    
    private class func canonicalHeaderList(request: NSURLRequest) -> String {
        var headers = [String]()
        
        request.allHTTPHeaderFields?.forEach {
            headers.append($0.0.lowercaseString)
        }
        
        return headers
            .sort { return $0 < $1 }
            .joinWithSeparator(";")
    }
    
    private class func canonicalContentHash(request: NSURLRequest) -> String {
        return request.valueForHTTPHeaderField("x-amz-content-sha256") ?? payloadHash(request: request)
    }
    
    /*
    *  MARK: String To Sign
    */
    
    class func stringToSign(request: NSURLRequest,
        region: AmazonS3Region,
        service: String,
        canonicalRequest: String) -> String {
            return "AWS4-HMAC-SHA256" + "\n" +
                requestDate(request) + "\n" +
                credentialScope(request, region: region, service: service) + "\n" +
                AmazonS3SignatureHelpers.hexEncode(AmazonS3SignatureHelpers.hashString(canonicalRequest))
    }
    
    private class func requestDate(request: NSURLRequest) -> String {
        return request.valueForHTTPHeaderField("X-Amz-Date") ?? ""
    }
    
    private class func credentialScope(request: NSURLRequest, region: AmazonS3Region, service: String) -> String {
        let date = requestDateWithoutTime(request)
        return date + "/" +
            region.rawValue + "/" +
            service + "/" +
        "aws4_request"
    }
    
    private class func requestDateWithoutTime(request: NSURLRequest) -> String {
        return requestDate(request).componentsSeparatedByString("T").first!
    }
    
    /*
    *  MARK: Signature
    */
    
    private class func signature(request: NSURLRequest,
        stringToSign: String,
        secret: String,
        region: AmazonS3Region,
        service: String) -> String {
            let signingKey = self.signingKey(request, secret: secret, region: region, service: service)
            let kSignature = AmazonS3SignatureHelpers.sha256HMacForString(stringToSign, withKey:signingKey, encoding: NSUTF8StringEncoding)
            return AmazonS3SignatureHelpers.hexEncode(NSString(data: kSignature, encoding: NSASCIIStringEncoding)! as String)
    }
    
    private class func signingKey(request: NSURLRequest,
        secret: String,
        region: AmazonS3Region,
        service: String) -> NSData {
            let secretData = ("AWS4" + secret).dataUsingEncoding(NSUTF8StringEncoding)
            let kDate = AmazonS3SignatureHelpers.sha256HMacForString(requestDateWithoutTime(request),
                withKey:secretData,
                encoding: NSUTF8StringEncoding)
            
            let kRegion = AmazonS3SignatureHelpers.sha256HMacForString(region.rawValue,
                withKey:kDate,
                encoding: NSASCIIStringEncoding)
            
            let kService = AmazonS3SignatureHelpers.sha256HMacForString(service,
                withKey:kRegion,
                encoding: NSUTF8StringEncoding)
            
            return AmazonS3SignatureHelpers.sha256HMacForString("aws4_request",
                withKey:kService,
                encoding: NSUTF8StringEncoding)
    }
    
}
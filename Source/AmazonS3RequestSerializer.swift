//
//  AmazonS3RequestSerializer.swift
//  AmazonS3RequestManager
//
//  Created by Anthony Miller on 10/14/15.
//  Copyright © 2015 Anthony Miller. All rights reserved.
//

import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)
    import MobileCoreServices
#elseif os(OSX)
    import CoreServices
#endif

import Alamofire

/**
 MARK: - AmazonS3RequestSerializer
 
 `AmazonS3RequestSerializer` serializes `NSURLRequest` objects for requests to the Amazon S3 service
 */
public class AmazonS3RequestSerializer {
    
    // MARK: - Instance Properties
    
    /**
    The Amazon S3 Bucket for the client
    */
    public var bucket: String?
    
    /**
     The Amazon S3 region for the client. `AmazonS3Region.USStandard` by default.
     
     :note: Must not be `nil`.
     
     :see: `AmazonS3Region` for defined regions.
     */
    public var region: AmazonS3Region = .USStandard
    
    /**
     The Amazon S3 Access Key ID used to generate authorization headers and pre-signed queries
     
     :dicussion: This can be found on the AWS control panel: http://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key
     */
    public var accessKey: String
    
    /**
     The Amazon S3 Secret used to generate authorization headers and pre-signed queries
     
     :dicussion: This can be found on the AWS control panel: http://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key
     */
    public var secret: String
    
    /**
     Whether to connect over HTTPS. `true` by default.
     */
    public var useSSL: Bool = true
    
    /**
     The AWS STS session token. `nil` by default.
     */
    public var sessionToken: String?
    
    // MARK: - Initialization
    
    /**
    Initalizes an `AmazonS3RequestSerializer` with the given Amazon S3 credentials.
    
    - parameter bucket:    The Amazon S3 bucket for the client
    - parameter region:    The Amazon S3 region for the client
    - parameter accessKey: The Amazon S3 access key ID for the client
    - parameter secret:    The Amazon S3 secret for the client
    
    - returns: An `AmazonS3RequestSerializer` with the given Amazon S3 credentials
    */
    public init(accessKey: String, secret: String, region: AmazonS3Region, bucket: String? = nil) {
        self.accessKey = accessKey
        self.secret = secret
        self.region = region
        self.bucket = bucket
    }
    
    /**
     MARK: - Amazon S3 Request Serialization
     
     This method serializes a request for the Amazon S3 service with the given method and path.
     
     :discussion: The `NSURLRequest`s returned from this method may be used with `Alamofire`, `NSURLSession` or any other network request manager.
     
     - parameter method:        The HTTP method for the request. For more information see `Alamofire.Method`.
     - parameter path:          The desired path, including the file name and extension, in the Amazon S3 Bucket.
     - parameter subresource:   The subresource to be added to the request's query. A subresource can be used to access
                                options or properties of a resource.
     - parameter acl:           The optional access control list to set the acl headers for the request. For more 
                                information see `AmazonS3ACL`.
     - parameter metaData:      An optional dictionary of meta data that should be assigned to the object to be uploaded.
     - parameter storageClass:  The optional storage class to use for the object to upload. If none is specified, 
                                standard is used. For more information see `AmazonS3StorageClass`.
     
     - returns: An `NSURLRequest`, serialized for use with the Amazon S3 service.
     */
    public func amazonURLRequest(method: Alamofire.Method,
        path: String? = nil,
        subresource: String? = nil,
        acl: AmazonS3ACL? = nil,
        metaData:[String : String]? = nil,
        storageClass: AmazonS3StorageClass = .Standard) -> NSURLRequest {
            let url = requestURL(path, subresource: subresource)
            
            var mutableURLRequest = NSMutableURLRequest(URL: url)
            mutableURLRequest.HTTPMethod = method.rawValue
            
            setContentType(forRequest: &mutableURLRequest)
            acl?.setACLHeaders(forRequest: &mutableURLRequest)
            setStorageClassHeaders(storageClass, forRequest: &mutableURLRequest)
            setMetaDataHeaders(metaData, forRequest: &mutableURLRequest)
            setAuthorizationHeaders(forRequest: &mutableURLRequest)
            
            return mutableURLRequest
    }
    
    private func requestURL(path: String?, subresource: String?) -> NSURL {
        var url = endpointURL
        if let path = path {
            url = url.URLByAppendingPathComponent(path)
        }
        
        if let subresource = subresource {
            url = url.URLByAppendingS3Subresource(subresource)
        }
        return url
    }
    
    /**
     A readonly endpoint URL created for the specified bucket, region, and SSL use preference. `AmazonS3RequestManager` uses this as the baseURL for all requests.
     */
    public var endpointURL: NSURL {
        var URLString = ""
        
        let scheme = self.useSSL ? "https" : "http"
        
        if bucket != nil {
            URLString = "\(scheme)://\(region.endpoint)/\(bucket!)"
            
        } else {
            URLString = "\(scheme)://\(region.endpoint)"
        }
        
        return NSURL(string: URLString)!
    }
    
    private func setContentType(inout forRequest request: NSMutableURLRequest) {
        let contentTypeString = MIMEType(request) ?? "application/octet-stream"
        
        request.setValue(contentTypeString, forHTTPHeaderField: "Content-Type")
    }
    
    private func MIMEType(request: NSURLRequest) -> String? {
        if let fileExtension = request.URL?.pathExtension where !fileExtension.isEmpty,
            let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, nil),
            MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTIRef.takeUnretainedValue(), kUTTagClassMIMEType) {
                
                UTIRef.release()
                
                let MIMEType = MIMETypeRef.takeUnretainedValue()
                MIMETypeRef.release()
                
                return MIMEType as String
                
        }
        return nil
    }
    
    private func setAuthorizationHeaders(inout forRequest request: NSMutableURLRequest) {
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        if sessionToken != nil {
            request.setValue(sessionToken!, forHTTPHeaderField: "x-amz-security-token")
        }
        
        let timestamp = currentTimeStamp()
        
        let signature = AmazonS3SignatureHelpers.AWSSignatureForRequest(request,
            timeStamp: timestamp,
            secret: secret)
        
        request.setValue(timestamp ?? "", forHTTPHeaderField: "Date")
        request.setValue("AWS \(accessKey):\(signature)", forHTTPHeaderField: "Authorization")
        
    }
    
    private func setStorageClassHeaders(storageClass: AmazonS3StorageClass, inout forRequest request: NSMutableURLRequest) {
        request.setValue(storageClass.rawValue, forHTTPHeaderField: "x-amz-storage-class")
    }
    
    private func setMetaDataHeaders(metaData:[String : String]?, inout forRequest request: NSMutableURLRequest) {
        guard let metaData = metaData else { return }
        
        for (key, value) in metaData {
            request.setValue(value, forHTTPHeaderField: "x-amz-meta-" + key)
        }
    }
    
    private func currentTimeStamp() -> String {
        return requestDateFormatter.stringFromDate(NSDate())
    }
    
    private lazy var requestDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        return dateFormatter
    }()
}

private extension NSURL {
    
    private func URLByAppendingS3Subresource(subresource: String) -> NSURL {
        if !subresource.isEmpty {
            let URLString = self.absoluteString.stringByAppendingString("?\(subresource)")
            return NSURL(string: URLString)!
            
        }
        return self
    }
    
}
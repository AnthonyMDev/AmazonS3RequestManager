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
open class AmazonS3RequestSerializer {
    
    // MARK: - Instance Properties
    
    /**
    The Amazon S3 Bucket for the client
    */
    open var bucket: String?
    
    /**
     The Amazon S3 region for the client. `AmazonS3Region.USStandard` by default.
     
     :note: Must not be `nil`.
     
     :see: `AmazonS3Region` for defined regions.
     */
    open var region: Region = .USStandard
    
    /**
     The Amazon S3 Access Key ID used to generate authorization headers and pre-signed queries
     
     :dicussion: This can be found on the AWS control panel: http://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key
     */
    open var accessKey: String
    
    /**
     The Amazon S3 Secret used to generate authorization headers and pre-signed queries
     
     :dicussion: This can be found on the AWS control panel: http://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key
     */
    open var secret: String
    
    /**
     Whether to connect over HTTPS. `true` by default.
     */
    open var useSSL: Bool = true
    
    /**
     The AWS STS session token. `nil` by default.
     */
    open var sessionToken: String?
    
    // MARK: - Initialization
    
    /**
    Initalizes an `AmazonS3RequestSerializer` with the given Amazon S3 credentials.
    
    - parameter bucket:    The Amazon S3 bucket for the client
    - parameter region:    The Amazon S3 region for the client
    - parameter accessKey: The Amazon S3 access key ID for the client
    - parameter secret:    The Amazon S3 secret for the client
    
    - returns: An `AmazonS3RequestSerializer` with the given Amazon S3 credentials
    */
    public init(accessKey: String, secret: String, region: Region, bucket: String? = nil) {
        self.accessKey = accessKey
        self.secret = secret
        self.region = region
        self.bucket = bucket
    }
    
    /**
     MARK: - Amazon S3 Request Serialization
     
     This method serializes a request for the Amazon S3 service with the given method and path.
     
     :discussion: The `URLRequest`s returned from this method may be used with `Alamofire`, `NSURLSession` or any other network request manager.
     
     - parameter method:        The HTTP method for the request. For more information see `Alamofire.Method`.
     - parameter path:          The desired path, including the file name and extension, in the Amazon S3 Bucket.
     - parameter subresource:   The subresource to be added to the request's query. A subresource can be used to access
                                options or properties of a resource.
     - parameter acl:           The optional access control list to set the acl headers for the request. For more 
                                information see `ACL`.
     - parameter metaData:      An optional dictionary of meta data that should be assigned to the object to be uploaded.
     - parameter storageClass:  The optional storage class to use for the object to upload. If none is specified, 
                                standard is used. For more information see `StorageClass`.
     
     - returns: A `URLRequest`, serialized for use with the Amazon S3 service.
     */
    open func amazonURLRequest(method: HTTPMethod,
                               path: String? = nil,
                               subresource: String? = nil,
                               acl: ACL? = nil,
                               metaData:[String : String]? = nil,
                               storageClass: StorageClass = .standard,
                               customParameters: [String : String]? = nil,
                               customHeaders: [String : String]? = nil) -> URLRequest {
        let url = requestURL(path, subresource: subresource, customParameters: customParameters)
        
        var mutableURLRequest = MutableURLRequest(url: url)
        mutableURLRequest.httpMethod = method.rawValue
        setContentType(on: &mutableURLRequest)
        acl?.setACLHeaders(on: &mutableURLRequest)
        setStorageClassHeaders(storageClass, on: &mutableURLRequest)
        setMetaDataHeaders(metaData, on: &mutableURLRequest)
        setCustomHeaders(customHeaders, on: &mutableURLRequest)
        setAuthorizationHeaders(on: &mutableURLRequest)
        
        return mutableURLRequest as URLRequest
    }
    
    fileprivate func requestURL(_ path: String?, subresource: String?, customParameters:[String : String]? = nil) -> URL {
        var url = endpointURL
        if let path = path {
            url = url.appendingPathComponent(path)
        }
        
        if let subresource = subresource {
            url = url.URLByAppendingS3Subresource(subresource)
        }
        
        if let customParameters = customParameters {
            for (key, value) in customParameters {
                url = url.URLByAppendingRequestParameter(key, value: value)
            }
        }
        
        return url
    }
    
    /**
     A readonly endpoint URL created for the specified bucket, region, and SSL use preference. `AmazonS3RequestManager` uses this as the baseURL for all requests.
     */
    open var endpointURL: URL {
        var URLString = ""
        
        let scheme = self.useSSL ? "https" : "http"
        
        if bucket != nil {
            URLString = "\(scheme)://\(region.endpoint)/\(bucket!)"
            
        } else {
            URLString = "\(scheme)://\(region.endpoint)"
        }
        
        return URL(string: URLString)!
    }
    
    fileprivate func setContentType(on request: inout MutableURLRequest) {
        let contentTypeString = MIMEType(for: request as URLRequest) ?? "application/octet-stream"
        
        request.setValue(contentTypeString, forHTTPHeaderField: "Content-Type")
    }
    
    fileprivate func MIMEType(for request: URLRequest) -> String? {
        if let fileExtension = request.url?.pathExtension , !fileExtension.isEmpty,
            let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil),
            let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTIRef.takeUnretainedValue(), kUTTagClassMIMEType) {
                
                UTIRef.release()
                
                let MIMEType = MIMETypeRef.takeUnretainedValue()
                MIMETypeRef.release()
                
                return MIMEType as String
                
        }
        return nil
    }
    
    fileprivate func setAuthorizationHeaders(on request: inout NSMutableURLRequest) {
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        if sessionToken != nil {
            request.setValue(sessionToken!, forHTTPHeaderField: "x-amz-security-token")
        }
        
        let timestamp = currentTimeStamp()
        
        let signature = AmazonS3SignatureHelpers.awsSignature(for: request as URLRequest!,
            timeStamp: timestamp,
            secret: secret)
        
        request.setValue(timestamp ?? "", forHTTPHeaderField: "Date")
        request.setValue("AWS \(accessKey):\(signature!)", forHTTPHeaderField: "Authorization")
        
    }
    
    fileprivate func setStorageClassHeaders(_ storageClass: StorageClass, on request: inout NSMutableURLRequest) {
        request.setValue(storageClass.rawValue, forHTTPHeaderField: "x-amz-storage-class")
    }
    
    fileprivate func setMetaDataHeaders(_ metaData:[String : String]?, on request: inout NSMutableURLRequest) {
        guard let metaData = metaData else { return }
        
        var metadataHeaders:[String:String] = [:]
        
        for (key, value) in metaData {
            metadataHeaders["x-amz-meta-" + key] = value
        }
        
        setCustomHeaders(metadataHeaders, on: &request)
    }
    
    fileprivate func setCustomHeaders(_ headerFields:[String : String]?, on request: inout NSMutableURLRequest) {
        guard let headerFields = headerFields else { return }
        
        for (key, value) in headerFields {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    fileprivate func currentTimeStamp() -> String {
        return requestDateFormatter.string(from: Date())
    }
    
    fileprivate lazy var requestDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter
    }()
}

private extension URL {
    
    func URLByAppendingS3Subresource(_ subresource: String) -> URL {
        if !subresource.isEmpty {
            let URLString = self.absoluteString + "?\(subresource)"
            return URL(string: URLString)!
            
        }
        return self
    }
    
    func URLByAppendingRequestParameter(_ key: String, value: String) -> URL {
        
        if key.isEmpty || value.isEmpty {
            return self
        }
        
        guard let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            return self
        }
        
        var URLString = self.absoluteString
        URLString = URLString + (URLString.range(of: "?") == nil ? "?" : "&") + key + "=" + encodedValue
        
        return URL(string: URLString)!
    }
    
}

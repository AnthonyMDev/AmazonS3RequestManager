//
// AmazonS3RequestManager.swift
// AmazonS3RequestManager
//
// Based on `AFAmazonS3Manager` by `Matt Thompson`
//
// Created by Anthony Miller. 2015.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

import Alamofire

/**
 MARK: Amazon S3 Storage Classes
 
 The possible Amazon Web Service Storage Classes for an upload.
 
 For more information about these classes and when you might want to use one over the other, including the pros and cons of each selection, see
 https://aws.amazon.com/blogs/aws/new-amazon-s3-reduced-redundancy-storage-rrs/
 
 - standard:                    Default storage class for all uploads. "If you store 10,000 objects with us, on average we may lose one of them every 10 million years or so. This storage is designed in such a way that we can sustain the concurrent loss of data in two separate storage facilities."
 
 - standardInfrequentAccess:    Infrequent Access storage class. Used for "data that is accessed less frequently, but requires rapid access when needed. Standard - IA offers the high durability, throughput, and low latency of Amazon S3 Standard, with a low per GB storage price and per GB retrieval fee. This combination of low cost and high performance make Standard - IA ideal for long-term storage, backups, and as a data store for disaster recovery. The Standard - IA storage class is set at the object level and can exist in the same bucket as Standard, allowing you to use lifecycle policies to automatically transition objects between storage classes without any application changes."
 
 - reducedRedundancy:           Reduced Redundancy storage class. "If you store 10,000 objects with us, on average we may lose one of them every year. RRS is designed to sustain the loss of data in a single facility."
 
 - glacier:                     Amazon Glacier service storage class. "Amazon Glacier is a secure, durable, and extremely low-cost storage service for data archiving. You can reliably store any amount of data at costs that are competitive with or cheaper than on-premises solutions. To keep costs low, Amazon Glacier is optimized for data that is rarely accessed and a retrieval time of several hours is suitable. Amazon Glacier supports lifecycle policies for automatic migration between storage classes. Please see the Amazon Glacier page for more details. "
 */
public enum StorageClass: String {
    case
    standard = "STANDARD",
    standardInfrequentAccess = "STANDARD_IA",
    reducedRedundancy = "REDUCED_REDUNDANCY",
    glacier = "GLACIER"
}

/**
 MARK: - AmazonS3RequestManager
 
 `AmazonS3RequestManager` manages the serialization of requests and responses to the Amazon S3 service using `Alamofire.Manager`.
 */
open class AmazonS3RequestManager {
    
    // MARK: - Instance Properties
    
    open var requestSerializer: AmazonS3RequestSerializer
    
    /**
     The `Alamofire.Manager` instance to use for network requests.
     
     :note: This defaults to the shared instance of `Manager` used by top-level Alamofire requests.
     */
    open var requestManager: SessionManager = SessionManager.default
    
    // MARK: - Initialization
    
    /**
     Initalizes an `AmazonS3RequestManager` with the given Amazon S3 credentials.
     
     - parameter bucket:    The Amazon S3 bucket for the client
     - parameter region:    The Amazon S3 region for the client
     - parameter accessKey: The Amazon S3 access key ID for the client
     - parameter secret:    The Amazon S3 secret for the client
     
     - returns: An `AmazonS3RequestManager` with the given Amazon S3 credentials and a default configuration.
     */
    required public init(bucket: String?, region: Region, accessKey: String, secret: String) {
        requestSerializer = AmazonS3RequestSerializer(accessKey: accessKey,
                                                      secret: secret,
                                                      region: region,
                                                      bucket: bucket)
    }
    
    // MARK: - GET Object Requests
    
    /**
     Gets an object from the Amazon S3 service and returns it as the response object without saving to file.
     
     :note: This method performs a standard GET request and does not allow use of progress blocks.
     
     - parameter at: The object path
     
     - returns: A GET request for the object
     */
    open func get(at path: String) -> DataRequest {
        return requestManager.request(requestSerializer.amazonURLRequest(method: .get, path: path))
            .responseS3Data { (response) -> Void in }
    }
    
    /**
     Gets an object from the Amazon S3 service and saves it to file.
     
     :note: The user for the manager's Amazon S3 credentials must have read access to the object
     
     :dicussion: This method performs a download request that allows for a progress block to be implemented. For more information on using progress blocks, see `Alamofire`.
     
     - parameter at:    The object path
     - parameter to:    The `NSURL` to save the object to
     
     - returns: A download request for the object
     */
    open func download(at path: String, to: @escaping DownloadRequest.DownloadFileDestination) -> DownloadRequest {
        let downloadRequest = requestSerializer.amazonURLRequest(method: .get, path: path)
        return requestManager.download(downloadRequest, to: to)
    }
    
    // MARK: PUT Object Requests
    
    /**
     Uploads an object to the Amazon S3 service with a given local file URL.
     
     :note: The user for the manager's Amazon S3 credentials must have read access to the bucket
     
     - parameter from:            The local `NSURL` of the file to upload
     - parameter to:              The desired destination path, including the file name and extension, in the Amazon S3 bucket
     - parameter acl:             The optional access control list to set the acl headers for the request. For more
                                  information see `ACL`.
     - parameter metaData:        An optional dictionary of meta data that should be assigned to the object to be uploaded.
     - parameter storageClass:    The optional storage class to use for the object to upload. If none is specified, standard is used. For more information see `StorageClass`.
     
     - returns: An upload request for the object
     */
    open func upload(from fileURL: URL,
                     to destinationPath: String,
                     acl: ACL? = nil,
                     metaData:[String : String]? = nil,
                     storageClass: StorageClass = .standard) -> UploadRequest {
        let putRequest = requestSerializer.amazonURLRequest(method: .put,
                                                            path: destinationPath,
                                                            acl: acl,
                                                            metaData: metaData,
                                                            storageClass: storageClass)
        
        return requestManager.upload(fileURL, with: putRequest)
    }
    
    /**
     Uploads an object to the Amazon S3 service with the given data.
     
     :note: The user for the manager's Amazon S3 credentials must have read access to the bucket
     
     - parameter data:            The `NSData` for the object to upload
     - parameter to:              The desired destination path, including the file name and extension, in the Amazon S3 bucket
     - parameter acl:             The optional access control list to set the acl headers for the request. 
                                  For more information see `ACL`.
     - parameter metaData:        An optional dictionary of meta data that should be assigned to the object to be uploaded.
     
     - parameter storageClass:    The optional storage class to use for the object to upload. If none is specified, 
                                  standard is used. For more information see `StorageClass`.
     
     - returns: An upload request for the object
     */
    open func upload(_ data: Data,
                     to destinationPath: String,
                     acl: ACL? = nil,
                     metaData:[String : String]? = nil,
                     storageClass: StorageClass = .standard) -> UploadRequest {
        let putRequest = requestSerializer.amazonURLRequest(method: .put,
                                                            path: destinationPath,
                                                            acl: acl,
                                                            metaData: metaData,
                                                            storageClass: storageClass)
        
        return requestManager.upload(data, with: putRequest)
    }
    
    // MARK: HEAD Object Request
    
    /**
     Retrieves metadata from an object without returning the object itself. This operation is useful if you are interested only in an object's metadata. To use HEAD, you must have READ access to the object.
     
     - parameter path: The object path
     
     - returns: A HEAD request for the object
     */
    open func getMetaData(forObjectAt path: String) -> DataRequest {
        let headRequest = requestSerializer.amazonURLRequest(method: .head, path: path)
        
        return requestManager.request(headRequest)
    }
    
    // MARK: COPY Object Request
    
    /**
     Copies an object to a target destination while preserving the object's meta data.
     
     - parameter from:  The object's source path
     - parameter to:    The object's target destination path on the bucket.
     
     - returns: The put request
     */
    open func copy(from sourcePath: String, to destinationPath: String) -> DataRequest {
        
        var completeSourcePath = "/"
        
        if let bucket = requestSerializer.bucket {
            completeSourcePath += bucket
            completeSourcePath += (sourcePath.hasPrefix("/") ? "" : "/") + sourcePath
        }
        
        let putRequest = requestSerializer.amazonURLRequest(method: .put,
                                                            path: destinationPath,
                                                            customHeaders: ["x-amz-copy-source" : completeSourcePath])
        
        return requestManager.request(putRequest)
    }
    
    // MARK: DELETE Object Request
    
    /**
     Deletes an object from the Amazon S3 service.
     
     - warning: Once an object has been deleted, there is no way to restore or undelete it.
     
     - parameter path: The object path
     
     - returns: The delete request
     */
    open func delete(at path: String) -> DataRequest {
        let deleteRequest = requestSerializer.amazonURLRequest(method: .delete, path: path)
        
        return requestManager.request(deleteRequest)
    }
    
    // MARK: GET Bucket Objects List Request
    
    /**
     Gets a list of object in a bucket. Returns up to 1000 objects.
     
     - note: This request returns meta data about the objects in the bucket. It does not return all of the bucket's object data.
     
     - parameter delimiter: A delimiter is a character you use to group keys.
     - parameter urlEncodeKeys: Requests Amazon S3 to URL encode the response.
     - parameter maxKeys: Sets the maximum number of keys returned in the response body. If you want to retrieve fewer than the default 1,000 keys, you can add this to your request.
     - parameter prefix: Limits the response to keys that begin with the specified prefix. You can use prefixes to separate a bucket into different groupings of keys. (You can think of using prefix to make groups in the same way you'd use a folder in a file system.)
     - parameter continuationToken: When the Amazon S3 response to this API call is truncated (that is, IsTruncated response element value is true), the response also includes the NextContinuationToken element, the value of which you can use in the next request as the continuation-token to list the next set of objects.
     - parameter fetchOwner: By default, the API does not return the Owner information in the response. If you want the owner information in the response, you can specify this parameter with the value set to true.
     - parameter startAfter: If you want the API to return key names after a specific object key in your key space, you can add this parameter. Amazon S3 lists objects in UTF-8 character encoding in lexicographical order.
     
     - returns: The get bucket object list request
     */
    open func listBucketObjects(delimiter: String? = nil,
                                urlEncodeKeys: Bool? = nil,
                                maxKeys: UInt? = nil,
                                prefix: String? = nil,
                                continuationToken: String? = nil,
                                fetchOwner: Bool? = nil,
                                startAfter: String? = nil) -> DataRequest {
        
        var requestParameters: [String : String] = [:]
        
        //Version 2 of the API requires this parameter and you must set its value to 2.
        requestParameters["list-type"] = "2"
        
        if let delimiter = delimiter {
            requestParameters["delimiter"] = delimiter
        }
        
        if let urlEncodeKeys = urlEncodeKeys {
            requestParameters["encoding-type"] = urlEncodeKeys ? "url" : ""
        }
        
        if let maxKeys = maxKeys {
            requestParameters["max-keys"] = "\(maxKeys)"
        }
        
        if let prefix = prefix {
            requestParameters["prefix"] = prefix
        }
        
        if let continuationToken = continuationToken {
            requestParameters["continuation-token"] = continuationToken
        }
        
        if let fetchOwner = fetchOwner {
            requestParameters["fetch-owner"] = fetchOwner ? "true" : "false"
        }
        
        if let startAfter = startAfter {
            requestParameters["start-after"] = startAfter
        }
        
        let listRequest = requestSerializer.amazonURLRequest(method: .get,
                                                             path: nil,
                                                             subresource: nil,
                                                             customParameters: requestParameters)
        
        return requestManager.request(listRequest)
    }
    
    // MARK: ACL Requests
    
    /**
     Gets the access control list (ACL) for the current `bucket`
     
     - note: To use this operation, you must have the `ACLPermission.readACL` for the bucket.
     
     - note: For more information on the ACL response headers for this request, see "http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGETacl.html"
     
     - returns: A GET request for the bucket's ACL
     */
    open func getBucketACL() -> DataRequest {
        return requestManager.request(requestSerializer.amazonURLRequest(method: .get,
                                                                         path: "",
                                                                         subresource: "acl",
                                                                         acl: nil))
    }
    
    /**
     Sets the access control list (ACL) for the current `bucket`
     
     - note: To use this operation, you must have the `ACLPermission.writeACL` for the bucket.
     
     For more information on the ACL response headers for this request, see "http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketPUTacl.html"
     
     - returns: A PUT request to set the bucket's ACL
     */
    open func setBucketACL(_ acl: ACL) -> DataRequest {
        return requestManager.request(requestSerializer.amazonURLRequest(method: .put,
                                                                         path: "",
                                                                         subresource: "acl",
                                                                         acl: acl))
    }
    
    /**
     Gets the access control list (ACL) for the object at the given path.
     
     - note: To use this operation, you must have the `ACLPermission.readACL` for the object.
     
     For more information on the ACL response headers for this request, see "http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGETacl.html"
     
     - parameter path: The object path
     
     - returns: A GET request for the object's ACL
     */
    open func getACL(forObjectAt path:String) -> DataRequest {
        return requestManager.request(requestSerializer.amazonURLRequest(method: .get,
                                                                         path: path,
                                                                         subresource: "acl"))
    }
    
    /**
     Sets the access control list (ACL) for the object at the given path.
     
     - note: To use this operation, you must have the `ACLPermission.writeACL` for the object.
     
     For more information on the ACL response headers for this request, see "http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectPUTacl.html"
     
     - returns: A PUT request to set the objects's ACL
     */
    open func setACL(_ acl: ACL, forObjectAt path: String) -> DataRequest {
        return requestManager.request(requestSerializer.amazonURLRequest(method: .put,
                                                                         path: path,
                                                                         subresource: "acl",
                                                                         acl: acl))
    }
    
}

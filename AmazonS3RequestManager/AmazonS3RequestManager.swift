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

// MARK: - Information

/**
MARK: Amazon S3 Regions

The possible Amazon Web Service regions for the client.

- USStandard:   N. Virginia or Pacific Northwest
- USWest1:      Oregon
- USWest2:      N. California
- EUWest1:      Ireland
- EUCentral1:   Frankfurt
- APSoutheast1: Singapore
- APSoutheast2: Sydney
- APNortheast1: Toyko
- SAEast1:      Sao Paulo
*/
public enum AmazonS3Region: String {
  case USStandard = "s3.amazonaws.com",
  USWest1 = "s3-us-west-1.amazonaws.com",
  USWest2 = "s3-us-west-2.amazonaws.com",
  EUWest1 = "s3-eu-west-1.amazonaws.com",
  EUCentral1 = "s3-eu-central-1.amazonaws.com",
  APSoutheast1 = "s3-ap-southeast-1.amazonaws.com",
  APSoutheast2 = "s3-ap-southeast-2.amazonaws.com",
  APNortheast1 = "s3-ap-northeast-1.amazonaws.com",
  SAEast1 = "s3-sa-east-1.amazonaws.com"
}

/**
MARK: Amazon S3 Storage Classes

The possible Amazon Web Service Storage Classes for an upload.

For more information about these classes and when you might want to use one over the other, including the pros and cons of each selection, see
https://aws.amazon.com/blogs/aws/new-amazon-s3-reduced-redundancy-storage-rrs/

- Standard:				Default storage class for all uploads. "If you store 10,000 objects with us, on average we may lose one of them every 10 million years or so. This storage is designed in such a way that we can sustain the concurrent loss of data in two separate storage facilities."
- ReducedRedundancy:    Reduced Redundancy storage class. "If you store 10,000 objects with us, on average we may lose one of them every year. RRS is designed to sustain the loss of data in a single facility."
*/
public enum AmazonS3StorageClass: String {
  case Standard = "STANDARD",
  ReducedRedundancy = "REDUCED_REDUNDANCY"
}

/**
MARK: - AmazonS3RequestManager

`AmazonS3RequestManager` manages the serialization of requests and responses to the Amazon S3 service using `Alamofire.Manager`.
*/
public class AmazonS3RequestManager {
  
  // MARK: - Instance Properties
  
  public var requestSerializer: AmazonS3RequestSerializer
  
  /**
  The `Alamofire.Manager` instance to use for network requests.
  
  :note: This defaults to the shared instance of `Manager` used by top-level Alamofire requests.
  */
  public var requestManager: Alamofire.Manager = Alamofire.Manager.sharedInstance
  
  // MARK: - Initialization
  
  /**
  Initalizes an `AmazonS3RequestManager` with the given Amazon S3 credentials.
  
  - parameter bucket:    The Amazon S3 bucket for the client
  - parameter region:    The Amazon S3 region for the client
  - parameter accessKey: The Amazon S3 access key ID for the client
  - parameter secret:    The Amazon S3 secret for the client
  
  - returns: An `AmazonS3RequestManager` with the given Amazon S3 credentials and a default configuration.
  */
  required public init(bucket: String?, region: AmazonS3Region, accessKey: String, secret: String) {
    requestSerializer = AmazonS3RequestSerializer(accessKey: accessKey,
      secret: secret,
      region: region,
      bucket: bucket)
  }
  
  // MARK: - GET Object Requests
  
  /**
  Gets and object from the Amazon S3 service and returns it as the response object without saving to file.
  
  :note: This method performs a standard GET request and does not allow use of progress blocks.
  
  - parameter path: The object path
  
  - returns: A GET request for the object
  */
  public func getObject(path: String) -> Request {
    return requestManager.request(requestSerializer.amazonURLRequest(.GET, path: path))
      .responseS3Data { (response) -> Void in }
  }
  
  /**
  Gets an object from the Amazon S3 service and saves it to file.
  
  :note: The user for the manager's Amazon S3 credentials must have read access to the object
  
  :dicussion: This method performs a download request that allows for a progress block to be implemented. For more information on using progress blocks, see `Alamofire`.
  
  - parameter path:           The object path
  - parameter destinationURL: The `NSURL` to save the object to
  
  - returns: A download request for the object
  */
  public func downloadObject(path: String, saveToURL destinationURL: NSURL) -> Request {
    return requestManager.download(
      requestSerializer.amazonURLRequest(.GET, path: path), destination: { (_, _) -> (NSURL) in
        return destinationURL
    })
  }
  
  // MARK: PUT Object Requests
  
  /**
  Uploads an object to the Amazon S3 service with a given local file URL.
  
  :note: The user for the manager's Amazon S3 credentials must have read access to the bucket
  
  - parameter fileURL:         The local `NSURL` of the file to upload
  - parameter destinationPath: The desired destination path, including the file name and extension, in the Amazon S3 bucket
  - parameter acl:             The optional access control list to set the acl headers for the request. For more information see `AmazonS3ACL`.
  
  - returns: An upload request for the object
  */
  public func putObject(fileURL: NSURL, destinationPath: String, acl: AmazonS3ACL? = nil, storageClass: AmazonS3StorageClass = .Standard) -> Request {
    let putRequest = requestSerializer.amazonURLRequest(.PUT, path: destinationPath, acl: acl, storageClass: storageClass)
    
    return requestManager.upload(putRequest, file: fileURL)
  }
  
  /**
  Uploads an object to the Amazon S3 service with the given data.
  
  :note: The user for the manager's Amazon S3 credentials must have read access to the bucket
  
  - parameter data:            The `NSData` for the object to upload
  - parameter destinationPath: The desired destination path, including the file name and extension, in the Amazon S3 bucket
  - parameter acl:             The optional access control list to set the acl headers for the request. For more information see `AmazonS3ACL`.
  - parameter storageClass:    The optional storage class to use for the object to upload. If none is specified, standard is used. For more information see `AmazonS3StorageClass`.
  
  - returns: An upload request for the object
  */
  public func putObject(data: NSData, destinationPath: String, acl: AmazonS3ACL? = nil, storageClass: AmazonS3StorageClass = .Standard) -> Request {
    let putRequest = requestSerializer.amazonURLRequest(.PUT, path: destinationPath, acl: acl, storageClass: storageClass)
    
    return requestManager.upload(putRequest, data: data)
  }
  
  // MARK: DELETE Object Request
  
  /**
  Deletes an object from the Amazon S3 service.
  
  :warning: Once an object has been deleted, there is no way to restore or undelete it.
  
  - parameter path: The object path
  
  - returns: The delete request
  */
  public func deleteObject(path: String) -> Request {
    let deleteRequest = requestSerializer.amazonURLRequest(.DELETE, path: path)
    
    return requestManager.request(deleteRequest)
  }
  
  // MARK: ACL Requests
  
  /**
  Gets the access control list (ACL) for the current `bucket`
  
  :note: To use this operation, you must have the `AmazonS3ACLPermission.ReadACL` for the bucket.
  
  :see: For more information on the ACL response headers for this request, see "http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGETacl.html"
  
  - returns: A GET request for the bucket's ACL
  */
  public func getBucketACL() -> Request {
    return requestManager.request(requestSerializer.amazonURLRequest(.GET, path: "", subresource: "acl", acl: nil))
  }
  
  /**
  Sets the access control list (ACL) for the current `bucket`
  
  :note: To use this operation, you must have the `AmazonS3ACLPermission.WriteACL` for the bucket.
  
  :see: For more information on the ACL response headers for this request, see "http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketPUTacl.html"
  
  - returns: A PUT request to set the bucket's ACL
  */
  public func setBucketACL(acl: AmazonS3ACL) -> Request {
    return requestManager.request(requestSerializer.amazonURLRequest(.PUT, path: "", subresource: "acl", acl: acl))
  }
  
  /**
  Gets the access control list (ACL) for the object at the given path.
  
  :note: To use this operation, you must have the `AmazonS3ACLPermission.ReadACL` for the object.
  
  :see: For more information on the ACL response headers for this request, see "http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGETacl.html"
  
  - parameter path: The object path
  
  - returns: A GET request for the object's ACL
  */
  public func getACL(forObjectAtPath path:String) -> Request {
    return requestManager.request(requestSerializer.amazonURLRequest(.GET, path: path, subresource: "acl"))
  }
  
  /**
  Sets the access control list (ACL) for the object at the given path.
  
  :note: To use this operation, you must have the `AmazonS3ACLPermission.WriteACL` for the object.
  
  :see: For more information on the ACL response headers for this request, see "http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectPUTacl.html"
  
  - returns: A PUT request to set the objects's ACL
  */
  public func setACL(forObjectAtPath path: String, acl: AmazonS3ACL) -> Request {
    return requestManager.request(requestSerializer.amazonURLRequest(.PUT, path: path, subresource: "acl", acl: acl))
  }
  
}
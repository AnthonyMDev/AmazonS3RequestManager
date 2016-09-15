//
//  AmazonS3ACL.swift
//  AmazonS3RequestManager
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

/// MARK: - Constants

private let AmazonS3PredefinedACLHeaderKey = "x-amz-acl"

/**
 MARK: - AmazonS3ACL Protocol
 
 An object conforming to the `AmazonS3ACL` protocol describes an access control list (ACL) that can be used by `AmazonS3RequestManager` to set the ACL Headers for a request.
 */
public protocol ACL {
    
    /**
     This method should be implemented to set the ACL headers for the object.
     */
    func setACLHeaders(on request: inout URLRequest)
    
}

/**
 MARK: - Predefined (Canned) ACLs.
 A list of predefined, or canned, ACLs recognized by the Amazon S3 service.
 
 :see: For more information on Predefined ACLs, see "http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl"
 
 - privateReadWrite:       Owner gets full control. No one else has access rights. This is the default ACL for a new bucket/object. Applies to buckets and objects.
 
 - publicReadWrite:        Owner gets full control. All other users (anonymous or authenticated) get READ and WRITE access. Granting this on a bucket is generally not recommended. Applies to buckets and objects.
 
 - publicReadOnly:         Owner gets full control. All other users (anonymous or authenticated) get READ access. Applies to buckets and objects.
 
 - authenticatedReadOnly:  Owner gets full control. All authenticated users get READ access. Applies to buckets and objects.
 
 - bucketOwnerReadOnly:    Object owner gets full control. Bucket owner gets READ access. Applies to objects only; if you specify this canned ACL when creating a bucket, Amazon S3 ignores it.
 
 - bucketOwnerFullControl: Both the object owner and the bucket owner get full control over the object. Applies to objects only; if you specify this canned ACL when creating a bucket, Amazon S3 ignores it.
 
 - logDeliveryWrite:       The `LogDelivery` group gets WRITE and READ_ACP permissions on the bucket.
 :see: For more information on logs, see "http://docs.aws.amazon.com/AmazonS3/latest/dev/ServerLogs.html"
 */
public enum PredefinedACL: String, ACL {
    
    case
    privateReadWrite = "private",
    publicReadWrite = "public-read-write",
    publicReadOnly = "public-read",
    authenticatedReadOnly = "authenticated-read",
    bucketOwnerReadOnly = "bucket-owner-read",
    bucketOwnerFullControl = "bucket-owner-full-control",
    logDeliveryWrite = "log-delivery-write"
    
    public func setACLHeaders(on request: inout URLRequest) {
        request.addValue(self.rawValue, forHTTPHeaderField: AmazonS3PredefinedACLHeaderKey)
    }
    
}

/**
 MARK: - ACL Permissions
 
 The list of permission types for the Amazon S3 Service
 
 :see: For more information on the access allowed by each permission, see "http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#permissions"
 
 - read:        Allows grantee to list the objects in the bucket or read the object data and its metadata
 
 - write:       Allows grantee to create, overwrite, and delete any object in the bucket.
 :note: This permission applies only to buckets.
 
 - readACL:     Allows grantee to read the ACL for the bucket or object
 
 - writeACL:    Allows grantee to write the ACL for the bucket or object
 
 - fullControl: Allows grantee the `read`, `write`, `readACL`, and `writeACL` permissions on the bucket or object
 
 */
public enum ACLPermission {
    case
    read,
    write,
    readACL,
    writeACL,
    fullControl
    
    var valueForRequestBody: String {
        switch (self) {
        case .read:
            return "READ"
        case .write:
            return "WRITE"
        case .readACL:
            return "READ_ACP"
        case .writeACL:
            return "WRITE_ACP"
        case .fullControl:
            return "FULL_CONTROL"
        }
    }
    
    var requestHeaderFieldKey: String {
        switch (self) {
        case .read:
            return "x-amz-grant-read"
        case .write:
            return "x-amz-grant-write"
        case .readACL:
            return "x-amz-grant-read-acp"
        case .writeACL:
            return "x-amz-grant-write-acp"
        case .fullControl:
            return "x-amz-grant-full-control"
        }
    }
    
}

/**
 MARK: - ACL Grantees
 
 Defines a grantee to assign to a permission.
 
 A grantee can be an AWS account or one of the predefined Amazon S3 groups. You grant permission to an AWS account by the email address or the canonical user ID.
 
 :note: If you provide an email in your grant request, Amazon S3 finds the canonical user ID for that account and adds it to the ACL. The resulting ACLs will always contain the canonical user ID for the AWS account, not the AWS account's email address.
 
 :see: For more information on Amazon S3 Service grantees, see "http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#specifying-grantee"
 
 - authenticatedUsers: This group represents all AWS accounts. Access permission to this group allows any AWS account to access the resource. However, all requests must be signed (authenticated).
 
 - allUsers:           Access permission to this group allows anyone to access the resource. The requests can be signed (authenticated) or unsigned (anonymous). Unsigned requests omit the Authentication header in the request.
 
 - logDeliveryGroup:   WRITE permission on a bucket enables this group to write server access logs to the bucket.
 :see: For more information on the log delivery group, see "http://docs.aws.amazon.com/AmazonS3/latest/dev/ServerLogs.html"
 
 - emailAddress:       A grantee for the AWS account with the given email address.
 
 - userID:             A grantee for the AWS account with the given canonical user ID.
 */
public enum ACLGrantee: Hashable {
    case authenticatedUsers,
    allUsers,
    logDeliveryGroup,
    emailAddress(String),
    userID(String)
    
    var requestHeaderFieldValue: String {
        switch (self) {
        case .authenticatedUsers:
            return "uri=\"http://acs.amazonaws.com/groups/global/AuthenticatedUsers\""
            
        case .allUsers:
            return "uri=\"http://acs.amazonaws.com/groups/global/AllUsers\""
            
        case .logDeliveryGroup:
            return "uri=\"http://acs.amazonaws.com/groups/s3/LogDelivery\""
            
        case .emailAddress(let email):
            return "emailAddress=\"\(email)\""
            
        case .userID(let id):
            return "id=\"\(id)\""
        }
    }
    
    public var hashValue: Int {
        get {
            return requestHeaderFieldValue.hashValue
        }
    }
}

public func ==(lhs: ACLGrantee, rhs: ACLGrantee) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

/**
 MARK: - ACL Permission Grants
 
 An `AmazonS3PermissionGrant` represents a grant for a single permission to a list of grantees.
 */
public struct ACLPermissionGrant: ACL, Hashable {
    
    /**
     Creates a grant with the given permission for a `Set` of grantees
     
     - parameter permission: The `ACLPermission` to set for the `grantees`
     - parameter grantees:   The `Set` of `ACLGrantees` to set the permission for
     
     - returns: An grant for the given permission and grantees
     */
    public init(permission: ACLPermission, grantees: Set<ACLGrantee>) {
        self.permission = permission
        self.grantees = grantees
    }
    
    /**
     Creates a grant with the given permission for a single grantee
     
     - parameter permission: The `ACLPermission` to set for the `grantee`
     - parameter grantees:   The single `ACLGrantees` to set the permission for
     
     - returns: An grant for the given permission and grantees
     */
    public init(permission: ACLPermission, grantee: ACLGrantee) {
        self.permission = permission
        self.grantees = [grantee]
    }
    
    /// The permission for the grant
    fileprivate(set) public var permission: ACLPermission
    
    /// The set of grantees for the grant
    fileprivate(set) public var grantees: Set<ACLGrantee>
    
    public func setACLHeaders(on request: inout URLRequest) {
        let granteeList =  granteeStrings().joined(separator: ", ")
        request.addValue(granteeList, forHTTPHeaderField: permission.requestHeaderFieldKey)
    }
    
    fileprivate func granteeStrings() -> [String] {
        var strings: [String] = []
        
        for grantee in grantees {
            strings.append(grantee.requestHeaderFieldValue)
        }
        
        return strings
    }
    
    public var hashValue: Int {
        get {
            return permission.hashValue
        }
    }
}

public func ==(lhs: ACLPermissionGrant, rhs: ACLPermissionGrant) -> Bool {
    return lhs.permission == rhs.permission
}

/**
 MARK: - Custom ACLs
 
 An `CustomACL` contains an array of `ACLPermissionGrant`s and can be used to create a custom access control list (ACL).
 
 :note: The Amazon S3 Service accepts a maximum of 100 permission grants per bucket/object.
 */
public struct CustomACL: ACL {
    
    /**
     The set of `AmazonS3ACLPermissionGrants` to use for the access control list
     
     :note: Only one `AmazonS3PermissionGrant` can be added to the set for each `AmazonS3ACLPermission` type. Each permission may map to multiple grantees.
     */
    public var grants: Set<ACLPermissionGrant>
    
    /**
     Initializes an `AmazonS3CustomACL` with a given array of `AmazonS3PermissionGrant`s.
     
     - parameter grant: The grants for the custom ACL
     
     - returns: An `AmazonS3CustomACL` with the given grants
     */
    public init(grants: Set<ACLPermissionGrant>) {
        self.grants = grants
        
    }
    
    public func setACLHeaders(on request: inout URLRequest) {
        for grant in grants {
            grant.setACLHeaders(on: &request)
        }
    }
    
}

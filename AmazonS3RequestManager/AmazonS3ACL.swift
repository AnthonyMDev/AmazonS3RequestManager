//
//  AmazonS3ACL.swift
//  AmazonS3RequestManager
//
//  Created by Anthony Miller on 6/9/15.
//  Copyright (c) 2015 Anthony Miller. All rights reserved.
//

import Foundation

/// MARK: - Constants

private let AmazonS3PredefinedACLHeaderKey = "x-amz-acl"

/**
MARK: - AmazonS3ACL Protocol

An object conforming to the `AmazonS3ACL` protocol describes an access control list (ACL) that can be used by `AmazonS3RequestManager` to set the ACL Headers for a request.
*/
public protocol AmazonS3ACL {
  
  /**
  This method should be implemented to set the ACL headers for the object.
  */
  func setACLHeaders(inout forRequest request: NSMutableURLRequest)
  
}

/**
MARK: - Predefined (Canned) ACLs.
A list of predefined, or canned, ACLs recognized by the Amazon S3 service.

:see: For more information on Predefined ACLs, see "http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl"

- Private:                Owner gets full control. No one else has access rights. This is the default ACL for a new bucket/object. Applies to buckets and objects.

- Public:                 Owner gets full control. All other users (anonymous or authenticated) get READ and WRITE access. Granting this on a bucket is generally not recommended. Applies to buckets and objects.

- PublicReadOnly:         Owner gets full control. All other users (anonymous or authenticated) get READ access. Applies to buckets and objects.

- AuthenticatedReadOnly:  Owner gets full control. All authenticated users get READ access. Applies to buckets and objects.

- BucketOwnerReadOnly:    Object owner gets full control. Bucket owner gets READ access. Applies to objects only; if you specify this canned ACL when creating a bucket, Amazon S3 ignores it.

- BucketOwnerFullControl: Both the object owner and the bucket owner get full control over the object. Applies to objects only; if you specify this canned ACL when creating a bucket, Amazon S3 ignores it.

- LogDeliveryWrite:       The `LogDelivery` group gets WRITE and READ_ACP permissions on the bucket.
  :see: For more information on logs, see "http://docs.aws.amazon.com/AmazonS3/latest/dev/ServerLogs.html"
*/
public enum AmazonS3PredefinedACL: String, AmazonS3ACL {
  
  case Private = "private",
  Public = "public-read-write",
  PublicReadOnly = "public-read",
  AuthenticatedReadOnly = "authenticated-read",
  BucketOwnerReadOnly = "bucket-owner-read",
  BucketOwnerFullControl = "bucket-owner-full-control",
  LogDeliveryWrite = "log-delivery-write"
  
  public func setACLHeaders(inout forRequest request: NSMutableURLRequest) {
    request.addValue(self.rawValue, forHTTPHeaderField: AmazonS3PredefinedACLHeaderKey)
  }
  
}

public enum AmazonS3ACLPermission {
  case Read,
  Write,
  ReadACL,
  WriteACL,
  FullControl
  
  var valueForRequestBody: String {
    switch (self) {
    case .Read:
      return "READ"
    case .Write:
      return "WRITE"
    case .ReadACL:
      return "READ_ACP"
    case .WriteACL:
      return "WRITE_ACP"
    case .FullControl:
      return "FULL_CONTROL"
    }
  }
  
  var requestHeaderFieldKey: String {
    switch (self) {
    case .Read:
      return "x-amz-grant-read"
    case .Write:
      return "x-amz-grant-write"
    case .ReadACL:
      return "x-amz-grant-read-acp"
    case .WriteACL:
      return "x-amz-grant-write-acp"
    case .FullControl:
      return "x-amz-grant-full-control"
    }
  }
  
}

public enum AmazonS3ACLGrantee {
  case AuthenticatedUsers,
  AllUsers,
  LogDeliveryGroup,
  EmailAddress(String),
  UserID(String)
  
  var requestHeaderFieldValue: String {
    switch (self) {
    case .AuthenticatedUsers:
      return "uri=\"http://acs.amazonaws.com/groups/global/AuthenticatedUsers\""
      
    case .AllUsers:
      return "uri=\"http://acs.amazonaws.com/groups/global/AllUsers\""
      
    case .LogDeliveryGroup:
      return "uri=\"http://acs.amazonaws.com/groups/s3/LogDelivery\""
      
    case .EmailAddress(let email):
      return "emailAddress=\"\(email)\""
      
    case .UserID(let id):
      return "id=\"\(id)\""
    }
  }
}

public struct AmazonS3ACLPermissionGrant: AmazonS3ACL, Hashable {
  
  public init(permission: AmazonS3ACLPermission, grantees: [AmazonS3ACLGrantee]) {
    self.permission = permission
    self.grantees = grantees
  }
  
  public init(permission: AmazonS3ACLPermission, grantee: AmazonS3ACLGrantee) {
    self.permission = permission
    self.grantees = [grantee]
  }
  
  var permission: AmazonS3ACLPermission
  
  var grantees: [AmazonS3ACLGrantee]
  
  public func setACLHeaders(inout forRequest request: NSMutableURLRequest) {
    let granteeStrings = grantees.map { (var grantee) -> String in
      return grantee.requestHeaderFieldValue
      
    }
    let granteeList = join(", ", granteeStrings)
    request.addValue(granteeList, forHTTPHeaderField: permission.requestHeaderFieldKey)
  }
  
  public var hashValue: Int {
    get {
      return permission.hashValue
    }
  }
}

public func ==(lhs: AmazonS3ACLPermissionGrant, rhs: AmazonS3ACLPermissionGrant) -> Bool {
  return lhs.permission == rhs.permission
}

/**
MARK: - Custom ACLs

An `AmazonS3CustomACL` contains an array of `AmazonS3ACLPermissionGrant`s and can be used to create a custom access control list (ACL).

:note: The Amazon S3 Service accepts a maximum of 100 permission grants per bucket/object.
*/
public struct AmazonS3CustomACL: AmazonS3ACL {
  
  /**
  The set of `AmazonS3ACLPermissionGrants` to use for the access control list
  
  :note: Only one `AmazonS3PermissionGrant` can be added to the set for each `AmazonS3ACLPermission` type. Each permission may map to multiple grantees.
  */
  public var grants: Set<AmazonS3ACLPermissionGrant>
  
  /**
  Initializes an `AmazonS3CustomACL` with a given array of `AmazonS3PermissionGrant`s.
  
  :param: grant The grants for the custom ACL
  
  :returns: An `AmazonS3CustomACL` with the given grants
  */
  public init(grants: Set<AmazonS3ACLPermissionGrant>) {
    self.grants = grants
    
  }
  
  public func setACLHeaders(inout forRequest request: NSMutableURLRequest) {
    for grant in grants {
      grant.setACLHeaders(forRequest: &request)
    }
  }
  
}
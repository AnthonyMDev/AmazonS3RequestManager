//
//  AmazonS3ACL.swift
//  AmazonS3RequestManager
//
//  Created by Anthony Miller on 6/9/15.
//  Copyright (c) 2015 Anthony Miller. All rights reserved.
//

import Foundation

private let AmazonS3PredefinedACLHeaderKey = "x-amz-acl"

public protocol AmazonS3ACL {
  
  func setACLHeaders(inout forRequest request: NSMutableURLRequest)
  
}

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

public struct AmazonS3CustomACL: AmazonS3ACL {
  
  public var grants: [AmazonS3ACLPermissionGrant]
  
  public init(grant: AmazonS3ACLPermissionGrant) {
    self.grants = [grant]
  }
  
  public init(grants: [AmazonS3ACLPermissionGrant]) {
   self.grants = grants
    
  }
  
  public func setACLHeaders(inout forRequest request: NSMutableURLRequest) {
    for grant in grants {
      grant.setACLHeaders(forRequest: &request)
    }
  }
  
}

public struct AmazonS3ACLPermissionGrant: AmazonS3ACL {
  
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
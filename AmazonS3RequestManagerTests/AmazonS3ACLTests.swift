//
//  AmazonS3ACLTests.swift
//  AmazonS3RequestManager
//
//  Created by Anthony Miller on 6/9/15.
//  Copyright (c) 2015 Anthony Miller. All rights reserved.
//

import Quick
import Nimble

import AmazonS3RequestManager

class AmazonS3ACLSpec: QuickSpec {
  override func spec() {
    
    describe("PredefinedACL") {
      
      context(".Private") {
        let acl = AmazonS3PredefinedACL.Private
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"] as? String
          expect(aclHeader).to(equal("private"))
        }
      }
      
      context(".Public") {
        let acl = AmazonS3PredefinedACL.Public
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"] as? String
          expect(aclHeader).to(equal("public-read-write"))
        }
      }
      
      context(".PublicReadOnly") {
        let acl = AmazonS3PredefinedACL.PublicReadOnly
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"] as? String
          expect(aclHeader).to(equal("public-read"))
        }
      }
      
      context(".AuthenticatedReadOnly") {
        let acl = AmazonS3PredefinedACL.AuthenticatedReadOnly
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"] as? String
          expect(aclHeader).to(equal("authenticated-read"))
        }
      }
      
      context(".BucketOwnerReadOnly") {
        let acl = AmazonS3PredefinedACL.BucketOwnerReadOnly
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"] as? String
          expect(aclHeader).to(equal("bucket-owner-read"))
        }
      }
      
      context(".BucketOwnerFullControl") {
        let acl = AmazonS3PredefinedACL.BucketOwnerFullControl
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"] as? String
          expect(aclHeader).to(equal("bucket-owner-full-control"))
        }
      }
      
      context(".LogDeliveryWrite") {
        let acl = AmazonS3PredefinedACL.LogDeliveryWrite
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"] as? String
          expect(aclHeader).to(equal("log-delivery-write"))
        }
      }
    }
    
    describe("Custom ACL") {
      
      context("Permission: Read") {
        let permission = AmazonS3ACLPermission.Read
        
        context("Grantee: Authenticated Users") {
          let grantee = AmazonS3ACLGrantee.AuthenticatedUsers
          let grant = AmazonS3ACLPermissionGrant(permission: permission, grantee: grantee)
          
          let acl = AmazonS3CustomACL(grant: grant)

          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"] as? String
            expect(aclHeader).to(equal("uri=\"http://acs.amazonaws.com/groups/global/AuthenticatedUsers\""))
          }
        }
      }
    }
  }
}
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
      
      describe("With Permission") {
        
        func aclWithPermission(permission: AmazonS3ACLPermission) -> AmazonS3CustomACL {
          let grantee = AmazonS3ACLGrantee.AuthenticatedUsers
          let grant = AmazonS3ACLPermissionGrant(permission: permission, grantee: grantee)
          
          return AmazonS3CustomACL(grant: grant)
        }
        
        describe("Read") {
          let permission = AmazonS3ACLPermission.Read
          let acl = aclWithPermission(permission)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"] as? String
            expect(aclHeader).toNot(beNil())
          }
        }
        
        describe("Write") {
          let permission = AmazonS3ACLPermission.Write
          let acl = aclWithPermission(permission)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-write"] as? String
            expect(aclHeader).toNot(beNil())
          }
        }
        
        describe("Read ACL") {
          let permission = AmazonS3ACLPermission.ReadACL
          let acl = aclWithPermission(permission)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read-acp"] as? String
            expect(aclHeader).toNot(beNil())
          }
        }
        
        describe("Write ACL") {
          let permission = AmazonS3ACLPermission.WriteACL
          let acl = aclWithPermission(permission)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-write-acp"] as? String
            expect(aclHeader).toNot(beNil())
          }
        }
        
        describe("Full Control") {
          let permission = AmazonS3ACLPermission.FullControl
          let acl = aclWithPermission(permission)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-full-control"] as? String
            expect(aclHeader).toNot(beNil())
          }
        }
      }
      describe("With Grantee") {
        
        func aclWithGrantee(grantee: AmazonS3ACLGrantee) -> AmazonS3ACL {
          let permission = AmazonS3ACLPermission.Read
          let grant = AmazonS3ACLPermissionGrant(permission: permission, grantee: grantee)
          
          return AmazonS3CustomACL(grant: grant)
        }
        
        describe("Grantee: Authenticated Users") {
          let grantee = AmazonS3ACLGrantee.AuthenticatedUsers
          let acl = aclWithGrantee(grantee)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"] as? String
            expect(aclHeader).to(equal("uri=\"http://acs.amazonaws.com/groups/global/AuthenticatedUsers\""))
          }
        }
        
        describe("Grantee: All Users") {
          let grantee = AmazonS3ACLGrantee.AllUsers
          let acl = aclWithGrantee(grantee)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"] as? String
            expect(aclHeader).to(equal("uri=\"http://acs.amazonaws.com/groups/global/AllUsers\""))
          }
        }
        
        describe("Grantee: Log Delivery Group") {
          let grantee = AmazonS3ACLGrantee.LogDeliveryGroup
          let acl = aclWithGrantee(grantee)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"] as? String
            expect(aclHeader).to(equal("uri=\"http://acs.amazonaws.com/groups/s3/LogDelivery\""))
          }
        }
        
        describe("Grantee: Email") {
          let grantee = AmazonS3ACLGrantee.EmailAddress("test@test.com")
          let acl = aclWithGrantee(grantee)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"] as? String
            expect(aclHeader).to(equal("emailAddress=\"test@test.com\""))
          }
        }
        
        describe("Grantee: User ID") {
          let grantee = AmazonS3ACLGrantee.UserID("123456")
          let acl = aclWithGrantee(grantee)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"] as? String
            expect(aclHeader).to(equal("id=\"123456\""))
          }
        }
      }
    }
  }
}

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
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
          expect(aclHeader).to(equal("private"))
        }
      }
      
      context(".Public") {
        let acl = AmazonS3PredefinedACL.Public
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
          expect(aclHeader).to(equal("public-read-write"))
        }
      }
      
      context(".PublicReadOnly") {
        let acl = AmazonS3PredefinedACL.PublicReadOnly
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
          expect(aclHeader).to(equal("public-read"))
        }
      }
      
      context(".AuthenticatedReadOnly") {
        let acl = AmazonS3PredefinedACL.AuthenticatedReadOnly
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
          expect(aclHeader).to(equal("authenticated-read"))
        }
      }
      
      context(".BucketOwnerReadOnly") {
        let acl = AmazonS3PredefinedACL.BucketOwnerReadOnly
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
          expect(aclHeader).to(equal("bucket-owner-read"))
        }
      }
      
      context(".BucketOwnerFullControl") {
        let acl = AmazonS3PredefinedACL.BucketOwnerFullControl
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
          expect(aclHeader).to(equal("bucket-owner-full-control"))
        }
      }
      
      context(".LogDeliveryWrite") {
        let acl = AmazonS3PredefinedACL.LogDeliveryWrite
        
        it("sets ACL request headers") {
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
          expect(aclHeader).to(equal("log-delivery-write"))
        }
      }
    }
    
    describe("ACL Permission Grant") {
      
      describe("With Permission") {
        
        func aclWithPermission(permission: AmazonS3ACLPermission) -> AmazonS3ACLPermissionGrant {
          let grantee = AmazonS3ACLGrantee.AuthenticatedUsers
          return AmazonS3ACLPermissionGrant(permission: permission, grantee: grantee)
          
        }
        
        describe("Read") {
          let permission = AmazonS3ACLPermission.Read
          let acl = aclWithPermission(permission)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
            expect(aclHeader).toNot(beNil())
          }
        }
        
        describe("Write") {
          let permission = AmazonS3ACLPermission.Write
          let acl = aclWithPermission(permission)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-write"]
            expect(aclHeader).toNot(beNil())
          }
        }
        
        describe("Read ACL") {
          let permission = AmazonS3ACLPermission.ReadACL
          let acl = aclWithPermission(permission)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read-acp"]
            expect(aclHeader).toNot(beNil())
          }
        }
        
        describe("Write ACL") {
          let permission = AmazonS3ACLPermission.WriteACL
          let acl = aclWithPermission(permission)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-write-acp"]
            expect(aclHeader).toNot(beNil())
          }
        }
        
        describe("Full Control") {
          let permission = AmazonS3ACLPermission.FullControl
          let acl = aclWithPermission(permission)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-full-control"]
            expect(aclHeader).toNot(beNil())
          }
        }
      }
      
      describe("With Grantee") {
        
        func aclWithGrantee(grantee: AmazonS3ACLGrantee) -> AmazonS3ACLPermissionGrant {
          let permission = AmazonS3ACLPermission.Read
          return AmazonS3ACLPermissionGrant(permission: permission, grantee: grantee)
          
        }
        
        describe("Grantee: Authenticated Users") {
          let grantee = AmazonS3ACLGrantee.AuthenticatedUsers
          let acl = aclWithGrantee(grantee)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
            expect(aclHeader).to(equal("uri=\"http://acs.amazonaws.com/groups/global/AuthenticatedUsers\""))
          }
        }
        
        describe("Grantee: All Users") {
          let grantee = AmazonS3ACLGrantee.AllUsers
          let acl = aclWithGrantee(grantee)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
            expect(aclHeader).to(equal("uri=\"http://acs.amazonaws.com/groups/global/AllUsers\""))
          }
        }
        
        describe("Grantee: Log Delivery Group") {
          let grantee = AmazonS3ACLGrantee.LogDeliveryGroup
          let acl = aclWithGrantee(grantee)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
            expect(aclHeader).to(equal("uri=\"http://acs.amazonaws.com/groups/s3/LogDelivery\""))
          }
        }
        
        describe("Grantee: Email") {
          let grantee = AmazonS3ACLGrantee.EmailAddress("test@test.com")
          let acl = aclWithGrantee(grantee)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
            expect(aclHeader).to(equal("emailAddress=\"test@test.com\""))
          }
        }
        
        describe("Grantee: User ID") {
          let grantee = AmazonS3ACLGrantee.UserID("123456")
          let acl = aclWithGrantee(grantee)
          
          it("sets ACL request headers") {
            var request = NSMutableURLRequest()
            acl.setACLHeaders(forRequest: &request)
            
            let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
            expect(aclHeader).to(equal("id=\"123456\""))
          }
        }
      }
      
      describe("With Multiple Grantees") {
        
        func aclWithGrantees(grantees: Set<AmazonS3ACLGrantee>) -> AmazonS3ACLPermissionGrant {
          let permission = AmazonS3ACLPermission.Read
          return AmazonS3ACLPermissionGrant(permission: permission, grantees: grantees)
          
        }
        
        it("sets ACL request headers") {
          let acl = aclWithGrantees([
            AmazonS3ACLGrantee.EmailAddress("test@test.com"),
            AmazonS3ACLGrantee.UserID("123456")])
          
          var request = NSMutableURLRequest()
          acl.setACLHeaders(forRequest: &request)
          
          let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
          expect(aclHeader).to(equal("emailAddress=\"test@test.com\", id=\"123456\""))
        }
      }
    }
  }
}

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
            
            context(".privateReadWrite") {
                let acl = PredefinedACL.privateReadWrite
                
                it("sets ACL request headers") {
                    var request = URLRequest(url: URL(string: "http://www.test.com")!)
                    acl.setACLHeaders(on: &request)
                    
                    let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
                    expect(aclHeader).to(equal("private"))
                }
            }
            
            context(".publicReadWrite") {
                let acl = PredefinedACL.publicReadWrite
                
                it("sets ACL request headers") {
                    var request = URLRequest(url: URL(string: "http://www.test.com")!)
                    acl.setACLHeaders(on: &request)
                    
                    let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
                    expect(aclHeader).to(equal("public-read-write"))
                }
            }
            
            context(".publicReadOnly") {
                let acl = PredefinedACL.publicReadOnly
                
                it("sets ACL request headers") {
                    var request = URLRequest(url: URL(string: "http://www.test.com")!)
                    acl.setACLHeaders(on: &request)
                    
                    let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
                    expect(aclHeader).to(equal("public-read"))
                }
            }
            
            context(".authenticatedReadOnly") {
                let acl = PredefinedACL.authenticatedReadOnly
                
                it("sets ACL request headers") {
                    var request = URLRequest(url: URL(string: "http://www.test.com")!)
                    acl.setACLHeaders(on: &request)
                    
                    let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
                    expect(aclHeader).to(equal("authenticated-read"))
                }
            }
            
            context(".bucketOwnerReadOnly") {
                let acl = PredefinedACL.bucketOwnerReadOnly
                
                it("sets ACL request headers") {
                    var request = URLRequest(url: URL(string: "http://www.test.com")!)
                    acl.setACLHeaders(on: &request)
                    
                    let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
                    expect(aclHeader).to(equal("bucket-owner-read"))
                }
            }
            
            context(".bucketOwnerFullControl") {
                let acl = PredefinedACL.bucketOwnerFullControl
                
                it("sets ACL request headers") {
                    var request = URLRequest(url: URL(string: "http://www.test.com")!)
                    acl.setACLHeaders(on: &request)
                    
                    let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
                    expect(aclHeader).to(equal("bucket-owner-full-control"))
                }
            }
            
            context(".logDeliveryWrite") {
                let acl = PredefinedACL.logDeliveryWrite
                
                it("sets ACL request headers") {
                    var request = URLRequest(url: URL(string: "http://www.test.com")!)
                    acl.setACLHeaders(on: &request)
                    
                    let aclHeader = request.allHTTPHeaderFields?["x-amz-acl"]
                    expect(aclHeader).to(equal("log-delivery-write"))
                }
            }
        }
        
        describe("ACL Permission Grant") {
            
            describe("With Permission") {
                
                func aclWithPermission(_ permission: ACLPermission) -> ACLPermissionGrant {
                    let grantee = ACLGrantee.authenticatedUsers
                    return ACLPermissionGrant(permission: permission, grantee: grantee)
                    
                }
                
                describe("read") {
                    let permission = ACLPermission.read
                    let acl = aclWithPermission(permission)
                    
                    it("sets ACL request headers") {
                        var request = URLRequest(url: URL(string: "http://www.test.com")!)
                        acl.setACLHeaders(on: &request)
                        
                        let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
                        expect(aclHeader).toNot(beNil())
                    }
                }
                
                describe("write") {
                    let permission = ACLPermission.write
                    let acl = aclWithPermission(permission)
                    
                    it("sets ACL request headers") {
                        var request = URLRequest(url: URL(string: "http://www.test.com")!)
                        acl.setACLHeaders(on: &request)
                        
                        let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-write"]
                        expect(aclHeader).toNot(beNil())
                    }
                }
                
                describe("readACL") {
                    let permission = ACLPermission.readACL
                    let acl = aclWithPermission(permission)
                    
                    it("sets ACL request headers") {
                        var request = URLRequest(url: URL(string: "http://www.test.com")!)
                        acl.setACLHeaders(on: &request)
                        
                        let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read-acp"]
                        expect(aclHeader).toNot(beNil())
                    }
                }
                
                describe("writeACL") {
                    let permission = ACLPermission.writeACL
                    let acl = aclWithPermission(permission)
                    
                    it("sets ACL request headers") {
                        var request = URLRequest(url: URL(string: "http://www.test.com")!)
                        acl.setACLHeaders(on: &request)
                        
                        let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-write-acp"]
                        expect(aclHeader).toNot(beNil())
                    }
                }
                
                describe("fullControl") {
                    let permission = ACLPermission.fullControl
                    let acl = aclWithPermission(permission)
                    
                    it("sets ACL request headers") {
                        var request = URLRequest(url: URL(string: "http://www.test.com")!)
                        acl.setACLHeaders(on: &request)
                        
                        let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-full-control"]
                        expect(aclHeader).toNot(beNil())
                    }
                }
            }
            
            describe("With Grantee") {
                
                func aclWithGrantee(_ grantee: ACLGrantee) -> ACLPermissionGrant {
                    let permission = ACLPermission.read
                    return ACLPermissionGrant(permission: permission, grantee: grantee)
                    
                }
                
                describe("Grantee: Authenticated Users") {
                    let grantee = ACLGrantee.authenticatedUsers
                    let acl = aclWithGrantee(grantee)
                    
                    it("sets ACL request headers") {
                        var request = URLRequest(url: URL(string: "http://www.test.com")!)
                        acl.setACLHeaders(on: &request)
                        
                        let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
                        expect(aclHeader).to(equal("uri=\"http://acs.amazonaws.com/groups/global/AuthenticatedUsers\""))
                    }
                }
                
                describe("Grantee: All Users") {
                    let grantee = ACLGrantee.allUsers
                    let acl = aclWithGrantee(grantee)
                    
                    it("sets ACL request headers") {
                        var request = URLRequest(url: URL(string: "http://www.test.com")!)
                        acl.setACLHeaders(on: &request)
                        
                        let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
                        expect(aclHeader).to(equal("uri=\"http://acs.amazonaws.com/groups/global/AllUsers\""))
                    }
                }
                
                describe("Grantee: Log Delivery Group") {
                    let grantee = ACLGrantee.logDeliveryGroup
                    let acl = aclWithGrantee(grantee)
                    
                    it("sets ACL request headers") {
                        var request = URLRequest(url: URL(string: "http://www.test.com")!)
                        acl.setACLHeaders(on: &request)
                        
                        let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
                        expect(aclHeader).to(equal("uri=\"http://acs.amazonaws.com/groups/s3/LogDelivery\""))
                    }
                }
                
                describe("Grantee: Email") {
                    let grantee = ACLGrantee.emailAddress("test@test.com")
                    let acl = aclWithGrantee(grantee)
                    
                    it("sets ACL request headers") {
                        var request = URLRequest(url: URL(string: "http://www.test.com")!)
                        acl.setACLHeaders(on: &request)
                        
                        let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
                        expect(aclHeader).to(equal("emailAddress=\"test@test.com\""))
                    }
                }
                
                describe("Grantee: User ID") {
                    let grantee = ACLGrantee.userID("123456")
                    let acl = aclWithGrantee(grantee)
                    
                    it("sets ACL request headers") {
                        var request = URLRequest(url: URL(string: "http://www.test.com")!)
                        acl.setACLHeaders(on: &request)
                        
                        let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
                        expect(aclHeader).to(equal("id=\"123456\""))
                    }
                }
            }
            
            describe("With Multiple Grantees") {
                
                func aclWithGrantees(_ grantees: Set<ACLGrantee>) -> ACLPermissionGrant {
                    let permission = ACLPermission.read
                    return ACLPermissionGrant(permission: permission, grantees: grantees)
                    
                }
                
                it("sets ACL request headers") {
                    let acl = aclWithGrantees([
                        ACLGrantee.emailAddress("test@test.com"),
                        ACLGrantee.userID("123456")])
                    
                    var request = URLRequest(url: URL(string: "http://www.test.com")!)
                    acl.setACLHeaders(on: &request)
                    
                    let aclHeader = request.allHTTPHeaderFields?["x-amz-grant-read"]
                    expect(aclHeader).to(contain("emailAddress=\"test@test.com\""))
                    expect(aclHeader).to(contain("id=\"123456\""))
                    expect(aclHeader).to(contain(", "))
                }
            }
        }
    }
}

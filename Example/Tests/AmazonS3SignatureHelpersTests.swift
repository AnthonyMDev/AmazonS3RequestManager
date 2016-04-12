//
//  AmazonS3SignatureHelpersTests.swift
//  AmazonS3RequestManager
//
//  Created by Sebastian Hunkeler on 12/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

@testable import AmazonS3RequestManager

class AmazonS3SignatureHelpersTests: XCTestCase {
  
  func test__canonicalizedResourceFromURL__escapesSpace() {
    // given
    let url = NSURL(string: "http://example.com/testbucket/")?.URLByAppendingPathComponent("demo file.txt")
    
    // when
    let canonicalizedPath = AmazonS3SignatureHelpers.canonicalizedResourceFromURL(url)
    
    // then
    XCTAssertEqual(canonicalizedPath, "/testbucket/demo%20file.txt")
  }

}

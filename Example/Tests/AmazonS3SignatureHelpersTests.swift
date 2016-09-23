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
    let url = URL(string: "http://example.com/testbucket/")!.appendingPathComponent("demo file.txt")
    
    // when
    let canonicalizedPath = AmazonS3SignatureHelpers.canonicalizedResource(from: url)
    
    // then
    XCTAssertEqual(canonicalizedPath, "/testbucket/demo%20file.txt")
  }

}

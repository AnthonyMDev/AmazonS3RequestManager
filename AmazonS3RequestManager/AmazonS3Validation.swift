//
//  AmazonS3Validation.swift
//  AmazonS3RequestManager
//
//  Created by Anthony Miller on 10/5/15.
//  Copyright © 2015 Anthony Miller. All rights reserved.
//

import Foundation

import Alamofire

extension Request {
  
  public func validateS3() -> Self {
    return validate { (_, response) in
      return .Success
    }
  }
  
}
//
//  AmazonS3ResponseSerialization.swift
//  AmazonS3RequestManager
//
//  Created by Anthony Miller on 10/5/15.
//  Copyright © 2015 Anthony Miller. All rights reserved.
//

import Foundation

import Alamofire
import SWXMLHash

extension Request {
  
  /**
  Creates a response serializer that parses any errors from the Amazon S3 Service and returns the associated data.
  
  - returns: A data response serializer
  */
  public static func s3DataResponseSerializer() -> ResponseSerializer<NSData?, NSError> {
    return ResponseSerializer { request, response, data, error in
      if let data = data {
        let xml = SWXMLHash.parse(data)
        if let errorCodeString = xml["Error"]["Code"].element?.text,
          error = AmazonS3Error(rawValue: errorCodeString) {
            let errorMessage = xml["Error"]["Message"].element?.text
            return .Failure(error.error(failureReason: errorMessage))
        }
      }
      
      guard error == nil else { return .Failure(error!) }
      
      return .Success(data)
    }
  }
  
  /**
  Adds a handler to be called once the request has finished.
  
  - parameter completionHandler: The code to be executed once the request has finished.
  
  - returns: The request.
  */
  public func responseS3Data(completionHandler: Response<NSData?, NSError> -> Void) -> Self {
    return response(responseSerializer: Request.s3DataResponseSerializer(), completionHandler: completionHandler)
  }
  
}
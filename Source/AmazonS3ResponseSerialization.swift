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
   Creates a response serializer that parses XML data and returns an XML indexer.
   
   - returns: A XML indexer
   */
  public static func XMLResponseSerializer() -> ResponseSerializer<XMLIndexer, NSError> {
    return ResponseSerializer { request, response, data, error in
      guard error == nil else { return .Failure(error!) }
      
      guard let validData = data else {
        let failureReason = "Data could not be serialized. Input data was nil."
        let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
        return .Failure(error)
      }
      
      // TODO: Check for parse error
      let xml = SWXMLHash.parse(validData)
      return .Success(xml)
    }
  }
    
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
  
  /**
   Adds a handler to be called once the request has finished.
   The handler passes the result data as a populated object determined by the generic response type paramter.
   
   - parameter completionHandler: The code to be executed once the request has finished.
   
   - returns: The request.
   */
  // TODO: Refactor into new serializer
  public func responseS3Object<T: ResponseObjectSerializable where T.RepresentationType == XMLIndexer>(completionHandler: Response<T, NSError> -> Void) -> Self {
    let responseSerializer = ResponseSerializer<T, NSError> { request, response, data, error in
      guard error == nil else { return .Failure(error!) }
      
      let XMLResponseSerializer = Request.XMLResponseSerializer()
      let result = XMLResponseSerializer.serializeResponse(request, response, data, error)
      
      switch result {
      case .Success(let value):
        if let response = response, responseObject = T(response: response, representation: value) {
          return .Success(responseObject)
        } else {
          let failureReason = "XML could not be serialized into response object: \(value)"
          let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
          return .Failure(error)
        }
      case .Failure(let error):
        return .Failure(error)
      }
    }
    
    return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
  }
  
}
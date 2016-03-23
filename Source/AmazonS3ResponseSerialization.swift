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
   Adds a handler to be called once the request has finished.
   The handler passes the result data as an `S3BucketObjectList`.
   
   - parameter completionHandler: The code to be executed once the request has finished.
   
   - returns: The request.
   */
  public func responseS3BucketObjectsList(completionHandler: Response<S3BucketObjectList, NSError> -> Void) -> Self {
    return responseS3Object(completionHandler)
  }
  
  /**
   Adds a handler to be called once the request has finished.
   The handler passes the result data as a populated object determined by the generic response type paramter.
   
   - parameter completionHandler: The code to be executed once the request has finished.
   
   - returns: The request.
   */
  public func responseS3Object<T: ResponseObjectSerializable where T.RepresentationType == XMLIndexer>
    (completionHandler: Response<T, NSError> -> Void) -> Self {
      return response(responseSerializer: Request.s3ObjectResponseSerializer(), completionHandler: completionHandler)
  }
  
  /**
   Creates a response serializer that serializes an object from an Amazon S3 response and parses any errors from the Amazon S3 Service.
   
   - returns: A data response serializer
   */
  static func s3ObjectResponseSerializer<T: ResponseObjectSerializable
    where T.RepresentationType == XMLIndexer>() -> ResponseSerializer<T, NSError> {
      return ResponseSerializer<T, NSError> { request, response, data, error in
        let result = XMLResponseSerializer().serializeResponse(request, response, data, nil)
        
        switch result {
        case .Success(let xml):
          if let error = amazonS3ResponseError(forXML: xml) ?? error { return .Failure(error) }
          
          if let response = response, responseObject = T(response: response, representation: xml) {
            return .Success(responseObject)
            
          } else {
            let failureReason = "XML could not be serialized into response object: \(xml)"
            let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
            return .Failure(error)
          }
          
        case .Failure(let error): return .Failure(error)
        }
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
   Creates a response serializer that parses any errors from the Amazon S3 Service and returns the associated data.
   
   - returns: A data response serializer
   */
  static func s3DataResponseSerializer() -> ResponseSerializer<NSData?, NSError> {
    return ResponseSerializer { request, response, data, error in
      if let data = data {
        
        let result = XMLResponseSerializer().serializeResponse(request, response, data, nil)
        
        switch result {
        case .Success(let xml):
          if let error = amazonS3ResponseError(forXML: xml) { return .Failure(error) }
          
        case .Failure(let error): return .Failure(error)
        }
      }
      
      guard error == nil else { return .Failure(error!) }
      
      return .Success(data)
    }
  }
  
  /**
   Creates a response serializer that parses XML data and returns an XML indexer.
   
   - returns: A XML indexer
   */
  static func XMLResponseSerializer() -> ResponseSerializer<XMLIndexer, NSError> {
    return ResponseSerializer { request, response, data, error in
      guard error == nil else { return .Failure(error!) }
      
      guard let validData = data else {
        let failureReason = "Data could not be serialized. Input data was nil."
        let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
        return .Failure(error)
      }
      
      let xml = SWXMLHash.parse(validData)
      return .Success(xml)
    }
  }
  
  private static func amazonS3ResponseError(forXML xml: XMLIndexer) -> NSError? {
    guard let errorCodeString = xml["Error"]["Code"].element?.text,
      error = AmazonS3Error(rawValue: errorCodeString) else { return nil }
    
    let errorMessage = xml["Error"]["Message"].element?.text
    return error.error(failureReason: errorMessage)
  }
  
}
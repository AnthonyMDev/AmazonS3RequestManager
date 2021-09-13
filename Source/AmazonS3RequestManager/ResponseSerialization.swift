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

extension DataRequest {
    
    /**
     Adds a handler to be called once the request has finished.
     The handler passes the result data as an `S3BucketObjectList`.
     
     - parameter completion: The code to be executed once the request has finished.
     
     - returns: The request.
     */
    @discardableResult
    public func responseS3BucketObjectsList(completion: @escaping (DataResponse<S3BucketObjectList>) -> Void) -> Self {
        return responseS3Object(completion: completion)
    }
    
    /**
     Adds a handler to be called once the request has finished.
     The handler passes the result data as a populated object determined by the generic response type paramter.
     
     - parameter completion: The code to be executed once the request has finished.
     
     - returns: The request.
     */
    @discardableResult
    public func responseS3Object<T: ResponseObjectSerializable>
        (completion: @escaping (DataResponse<T>) -> Void) -> Self where T.RepresentationType == XMLIndexer {
        return response(responseSerializer: DataRequest.s3ObjectResponseSerializer(), completionHandler: completion)
    }
    
    /**
     Creates a response serializer that serializes an object from an Amazon S3 response and parses any errors from the Amazon S3 Service.
     
     - returns: A data response serializer
     */
    static func s3ObjectResponseSerializer<T: ResponseObjectSerializable>() -> DataResponseSerializer<T>
        where T.RepresentationType == XMLIndexer {
        return DataResponseSerializer<T> { request, response, data, error in
            let result = XMLResponseSerializer().serializeResponse(request, response, data, nil)
            
            switch result {
            case .success(let xml):
                if let error = amazonS3ResponseError(forXML: xml) ?? error { return .failure(error) }
                
                if let response = response, let responseObject = T(response: response, representation: xml) {
                    return .success(responseObject)
                    
                } else {
                    let failureReason = "XML could not be serialized into response object: \(xml)"
                    let userInfo: [String: Any] = [NSLocalizedFailureReasonErrorKey: failureReason]
                    let errorCode = AFError.responseSerializationFailed(reason: .inputDataNil)._code
                    let error = NSError(domain: S3Error.Domain, code: errorCode, userInfo: userInfo)
                    return .failure(error)
                }
                
            case .failure(let error): return .failure(error)
            }
        }
    }
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter completion: The code to be executed once the request has finished.
     
     - returns: The request.
     */
    @discardableResult
    public func responseS3Data(completion: @escaping (DataResponse<Data>) -> Void) -> Self {
        return response(responseSerializer: DataRequest.s3DataResponseSerializer(), completionHandler: completion)
    }
    
    /**
     Creates a response serializer that parses any errors from the Amazon S3 Service and returns the associated data.
     
     - returns: A data response serializer
     */
    static func s3DataResponseSerializer() -> DataResponseSerializer<Data> {
        return DataResponseSerializer { request, response, data, error in
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            let result = XMLResponseSerializer().serializeResponse(request, response, data, nil)
            
            switch result {
            case .success(let xml):
                if let error = amazonS3ResponseError(forXML: xml) { return .failure(error) }
                
            case .failure(let error): return .failure(error)
            }
            
            guard error == nil else { return .failure(error!) }
            
            return .success(data)
        }
    }
    
    /**
     Creates a response serializer that parses XML data and returns an XML indexer.
     
     - returns: A XML indexer
     */
    static func XMLResponseSerializer() -> DataResponseSerializer<XMLIndexer> {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let validData = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            let xml = SWXMLHash.parse(validData)
            return .success(xml)
        }
    }
    
    /**
     Adds a handler to be called once the request has finished.
     The handler passes the AmazonS3 meta data from the response's headers.
     
     - parameter completion: The code to be executed once the request has finished.
     
     - returns: The request.
     */
    @discardableResult
    public func responseS3MetaData(completion: @escaping (DataResponse<S3ObjectMetaData>) -> Void) -> Self {
        return response(responseSerializer: DataRequest.s3MetaDataResponseSerializer(), completionHandler: completion)
    }
    
    /**
     Creates a response serializer that parses any errors from the Amazon S3 Service and returns the response's meta data.
     
     - returns: A metadata response serializer
     */
    static func s3MetaDataResponseSerializer() -> DataResponseSerializer<S3ObjectMetaData> {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let response = response else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            guard let metaData = S3ObjectMetaData(response: response) else {
                let failureReason = "No meta data was found."
                let userInfo: [String: Any] = [NSLocalizedFailureReasonErrorKey: failureReason]
                let errorCode = AFError.responseSerializationFailed(reason: .inputDataNil)._code
                let error = NSError(domain: S3Error.Domain, code: errorCode, userInfo: userInfo)
                return .failure(error)
            }
            
            return .success(metaData)
        }
    }
    
    /*
     *  MARK: - Errors
     */
    
    fileprivate static func amazonS3ResponseError(forXML xml: XMLIndexer) -> Error? {
        guard let errorCodeString = xml["Error"]["Code"].element?.text,
            let error = S3Error(rawValue: errorCodeString) else { return nil }
        
        let errorMessage = xml["Error"]["Message"].element?.text
        return error.error(failureReason: errorMessage)
    }
    
}

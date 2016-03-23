//
//  AmazonS3ResponseObjects.swift
//  AmazonS3RequestManager
//
//  Created by Sebastian Hunkeler on 17/03/16.
//
//

import Foundation
import SWXMLHash

/**
 Protocol for serializable object classes.
 */
public protocol ResponseObjectSerializable {
    
    /// The type of the data that represents the object.
    typealias RepresentationType
    
    init?(response: NSHTTPURLResponse, representation: RepresentationType)
}

/**
 Struct for holding attributes of a file representation returned by an S3 instance.
 */
// TODO: Document properties
public struct S3File {
    public let path: String
    public let modified: NSDate
    public let size: Int
    public let storageClass: AmazonS3StorageClass?
    public let owner: (id: String, name: String)?
}

/**
 Class for representing the result data of a LIST operation on an S3 instance.
 */
public final class S3BucketObjectList: ResponseObjectSerializable {
    public var files: [S3File] = []
    public var bucket: String?
    public var truncated: Bool?
    public var maxKeys: Int?
    
    public init?(response: NSHTTPURLResponse, representation xml: XMLIndexer) {
        bucket = xml["ListBucketResult"]["Name"].element?.text
        
        if let isTruncated = xml["ListBucketResult"]["IsTruncated"].element?.text {
            truncated = Bool(isTruncated == "true")
        }
        
        if let maximumKeys = xml["ListBucketResult"]["MaxKeys"].element?.text {
            maxKeys = Int(maximumKeys)
        }
        
        parseContents(xml["ListBucketResult"]["Contents"])
    }
    
    private func dateFromS3Date(rawDate: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.dateFromString(rawDate)
    }
    
    private func parseContents(xml: XMLIndexer) {
        for element in xml {
            // TODO: Remove explicit unwraps
            let file = S3File(
                path: (element["Key"].element?.text)!,
                modified: dateFromS3Date((element["LastModified"].element?.text)!)!,
                size: Int((element["Size"].element?.text)!)!,
                storageClass: AmazonS3StorageClass(rawValue: (element["StorageClass"].element?.text)!),
                owner: ((element["Owner"]["ID"].element?.text)!,(element["Owner"]["DisplayName"].element?.text)!)
            )
            
            files.append(file)
        }
    }
    
}
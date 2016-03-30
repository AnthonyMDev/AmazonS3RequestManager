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
    associatedtype RepresentationType
    
    init?(response: NSHTTPURLResponse, representation: RepresentationType)
}

/**
 Struct for holding attributes of a file representation returned by an S3 instance.
 */
public struct S3File {
    
    /// The path to the file within its bucket.
    public let path: String
    
    /// The date the file was last modified.
    public let lastModifiedDate: NSDate
    
    /// The size in bytes of the object
    public let size: Float
    
    /// An MD5 hash of the object. This only reflects changes to the contents of an object, not its metadata.
    public let entityTag: String?
    
    /// The `AmazonS3StorageClass` of the file.
    public let storageClass: AmazonS3StorageClass?
    
    /// The owner of the file as a tuple containing the owner's Display Name and ID.
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
    
    private func parseContents(xml: XMLIndexer) {
        for element in xml {
            if let file = parseFile(element) {
                files.append(file)
            }
        }
    }
    
    private func parseFile(xml: XMLIndexer) -> S3File? {
        guard let path = xml["Key"].element?.text,
            dateString = xml["LastModified"].element?.text,
            date =  dateFromS3Date(dateString),
            sizeString = xml["Size"].element?.text,
            size = Float(sizeString) else { return nil }

        var storageClass: AmazonS3StorageClass?
        if let storageClassString = xml["StorageClass"].element?.text {
            storageClass = AmazonS3StorageClass(rawValue: storageClassString)
        }
        
        var owner: (String, String)?
        if let ownerId = xml["Owner"]["ID"].element?.text,
            ownerName = xml["Owner"]["DisplayName"].element?.text {
                owner = (ownerId, ownerName)
        }
        
        return S3File(
            path: path,
            lastModifiedDate: date,
            size: size,
            entityTag: xml["ETag"].element?.text,
            storageClass: storageClass,
            owner: owner)
    }
    
    private func dateFromS3Date(rawDate: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.dateFromString(rawDate)
    }
    
}

/**
Class for representing the meta data values for an object from the Amazon S3 Service.
*/
public final class S3ObjectMetaData: ResponseObjectSerializable {
    
    /// A dictionary of the meta data values for the object.
    public var metaData: [String : String] = [:]
    
    public init?(response: NSHTTPURLResponse, representation: Any) {
        if let headers = response.allHeaderFields as? [String : String] {
            
            for (header,value) in headers {
                let prefix = "x-amz-meta-"
                if header.hasPrefix(prefix) {
                    let trimmedHeaderName = header.substringFromIndex(prefix.startIndex.advancedBy(prefix.characters.count))
                    metaData[trimmedHeaderName] = value
                }
            }
            
        }
    }
}
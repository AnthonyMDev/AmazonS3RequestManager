# AmazonS3RequestManager
[![Version](https://img.shields.io/cocoapods/v/AmazonS3RequestManager.svg?style=flat)](http://cocoapods.org/pods/AmazonS3RequestManager)
[![License](https://img.shields.io/cocoapods/l/AmazonS3RequestManager.svg?style=flat)](http://cocoapods.org/pods/AmazonS3RequestManager)
[![Platform](https://img.shields.io/cocoapods/p/AmazonS3RequestManager.svg?style=flat)](http://cocoapods.org/pods/AmazonS3RequestManager)
[![Build Status](https://travis-ci.org/AnthonyMDev/AmazonS3RequestManager.svg?branch=master)](https://travis-ci.org/AnthonyMDev/AmazonS3RequestManager)
[![Contact me on Codementor](https://cdn.codementor.io/badges/contact_me_github.svg)](https://www.codementor.io/anthonymdev?utm_source=github&utm_medium=button&utm_term=anthonymdev&utm_campaign=github)

An Alamofire based request manager that serializes requests to the AWS S3 (Amazon Simple Storage Solution).

`AmazonS3RequestManager` also includes a request serializer that creates `URLRequest` objects for use with any other networking methods.

## Features

- [x] Request Serialization
- [x] Response Validation
- [x] Amazon S3 Response Error Parsing
- [x] Access Control List (ACL) Management
- [x] Support for Amazon S3 Subresources
- [x] Support for Amazon S3 Storage Classes
- [x] Comprehensive Unit Test Coverage
- [x] [Complete Documentation](http://cocoadocs.org/docsets/AmazonS3RequestManager)

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

To integrate AmazonS3RequestManager into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

// For Swift 2.0
pod 'AmazonS3RequestManager', '~> 0.10'
```

Then, run the following command:

```bash
$ pod install
```

## Usage
First create an instance of the manager.

```swift
let amazonS3Manager = AmazonS3RequestManager(bucket: myAmazonS3Bucket,
    region: .USStandard,
    accessKey: myAmazonS3AccessKey,
    secret: myAmazonS3Secret)
```

### List Bucket Objects
Gets a list of object in a bucket:

```swift
amazonS3Manager.listBucketObjects().responseS3Object { (response: DataResponse<S3BucketObjectList, NSError>) in
    if let files = response.result.value?.files {
        for file in files {
            print(file.path)
        }
    }
}
```

### Get Objects

Getting Objects as Response Objects:

```swift
amazonS3Manager.get(at: "myFolder/fileName.jpg")
```

Saving Objects To File:

```swift
let destinationURL: URL = FileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
let destination: DownloadRequest.DownloadFileDestination = { _, _ in destinationURL, []) }
amazonS3Manager.download(at: "myFolder/fileName.jpg", to: destination)
```
    
### Get Metadata
Retrieve metadata from an object without returning the object itself:

```swift
amazonS3Manager.getMetaData(forObjectAt: "fileName.txt").responseS3MetaData { (response: DataResponse<S3ObjectMetaData, NSError>) in
    if let metaData = response.result.value?.metaData {
        for objectMetaData in metaData {
            print(objectMetaData)
        }
    }
}
```

### Upload Objects
```swift
let fileURL: NSURL = NSURL(fileURLWithPath: "pathToMyObject")
amazonS3Manager.upload(from: fileURL, to: "pathToSaveObjectTo/fileName.jpg")
```

### Copy Objects
```swift
amazonS3Manager.copy(from: "demo.txt", to: "copy.txt").response { request, response, data, error in    
    print(response)    
    print(error)
}
```
    
### Delete Objects
```swift
amazonS3Manager.delete(at: "myFolder/fileName.jpg")
```

## Response Serialization
`AmazonS3RequestManager` includes a custom data response serializer that parses errors from the Amazon S3 Service.

```swift
amazonS3Manager.getObject("myFolder/fileName.jpg")
  .responseS3Data { (response) -> Void in
    // Handle Response Data or Error
}
```

## Access Control Lists (ACL)

`AmazonS3RequestManager` provides simple APIs for getting and setting ACLs on buckets and objects.

### Getting ACLs

You can retrieve the ACLs for the current bucket set on the request manager with a `GET` request:

```swift
amazonS3Manager.getBucketACL()
```
    
or for an object in the bucket with a `GET` request:

```swift
amazonS3Manager.getACL(forObjectAt: "myFolder/fileName.jpg")
```
    
### Setting ACLs

You can set the ACLs on the current bucket with a `PUT` request: 

```swift
amazonS3Manager.setBucketACL(AmazonS3PredefinedACL.Public)
```

or on an object in the bucket with a `PUT` request:

```swift
amazonS3Manager.setACL(acl: PredefinedACL.publicReadWrite, forObjectAt: "myFolder/fileName.jpg")
```

The ACLs for an object can also be set while uploading by using the optional `acl` parameter.

### Creating Custom ACLs

If the predefined ACLs that the Amazon S3 Service provides do not give you enough control, you may create custom ACLs using `AmazonS3ACLPermissionGrant` and `AmazonS3CustomACL`

`AmazonS3ACLPermissionGrant` grants multiple users/user groups a single permission.
`AmazonS3CustomACL` is comprised of multiple `AmazonS3ACLPermissionGrant`s to create any series of permissions you would like to create.

#### Examples

To give all users read access to the bucket:

```swift
let readPermission = AmazonS3ACLPermissionGrant(permission: .Read, grantee: .AllUsers)
amazonS3Manager.setBucketACL(readPermission)
```

To give all users read access to the bucket, authenticated users write access to the bucket, and two users with a given E-mail Address and given User ID full control:

```swift
let readPermission = AmazonS3ACLPermissionGrant(permission: .Read, grantee: .AllUsers)
let writePermission = AmazonS3ACLPermissionGrant(permission: .Write, grantee: .AuthenticatedUsers)
let fullControlPermission = AmazonS3ACLPermissionGrant(permission: .FullControl, grantees: [.EmailAddress("admin@myDomain.com"), .UserID("my-user-id")])
let customACL = AmazonS3CustomACL(grants: [readPermission, writePermission, fullControlPermission])
amazonS3Manager.setBucketACL(customACL)
```

#### 1.0.0 Migration

Version 1.0.0 changes the names public classes and functions to adopt the recommended syntax from the Swift API Design Guidelines. The language version has also been updated to use Swift 3.0.

- Removes `AmazonS3` prefix from some objects, classes, and enums.
- `ACL` protocol method parameter name changed from `setACLHeaders(forRequest:)` to 'setACLHeaders(on:)`.
- `PredefinedACL` case name changes
	- `Private` -> `privateReadWrite`
	- `Public` -> `publicReadWrite`	
- Changed request method names on `AmazonS3RequestManager`.
	- `getObject(path:)` -> `get(at:)`
	- `downloadObject(path:saveToURL:)` -> `download(at:to:)`
	- `putObject(fileURL:destinationPath:acl:metaData:storageClass:)` -> `upload(from:to:acl:metaData:storageClass:)`
	- `putObject(data:destinationPath:acl:metaData:storageClass:)` -> `upload(_:to:acl:metaData:storageClass:)`
	- `headObject(path:)` -> `getMetaData(forObjectAt:)`
	- `copyObject(_:destinationPath:)` -> `copy(from:to:)`
	- `deleteObject(_:)` -> `delete(at:)`
	- `getACL(forObjectAtPath:)` -> `getACL(forObjectAt:)`
	- `setACL(forObjectAtPath:acl:)` -> `setACL(_:forObjectAt:)`
- Alamofire now uses a `DownloadFileDestination` to configure the destination for download requests. You will need to migrate all download requests to use this time, rather than just the destination URL.



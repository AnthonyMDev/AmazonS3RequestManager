# AmazonS3RequestManager
A Alamofire based request manager that serializes requests to the AWS S3 (Amazon Simple Storage Solution). Based on AFAmazonS3Manager

## Usage
First create an instance of the manager.

    let amazonS3Manager = AmazonS3RequestManager(bucket: myAmazonS3Bucket,
        region: .USStandard,
        accessKey: myAmazonS3AccessKey,
        secret: myAmazonS3Secret)

### Get Objects

Getting Objects as Response Objects:

    amazonS3Manager.getObject("myFoler/fileName.jpg")

Saving Objects To File:

    let destination: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    amazonS3Manager.downloadObject("myFolder/fileName.jpg", saveToURL: destination)
    
### Upload Objects
    let fileURL: NSURL = NSURL(fileURLWithPath: "pathToMyObject")
    amazonS3Manager.putObject(fileURL, destinationPath: "pathToSaveObjectTo/fileName.jpg")
    
### Delete Objects

    amazonS3Manager.deleteObject("myFolder/fileName.jpg")

## Access Control Lists (ACL)

`AmazonS3RequestManager` provides simple APIs for getting and setting ACLs on buckets and objects.

### Getting ACLs

You can retrieve the ACLs for the current bucket set on the request manager with a `GET` request:

    amazonS3Manager.getBucketACL()
    
or for an object in the bucket with a `GET` request:

    amazonS3Manager.getACL(forObjectAtPath: "myFolder/fileName.jpg")
    
### Setting ACLs

You can set the ACLs on the current bucket with a `PUT` request:

    amazonS3Manager.setBucketACL(AmazonS3PredefinedACL.Public)
    
or on an object in the bucket with a `PUT` request:

    amazonS3Manager.setACL(forObjectAtPath: "myFolder/fileName.jpg", acl: AmazonS3PredefinedACL.Public)
    
The ACLs for an object can also be set while uploading by using the optional `acl` parameter.

### Creating Custom ACLs

If the predefined ACLs that the Amazon S3 Service provides do not give you enough control, you may create custom ACLs using `AmazonS3ACLPermissionGrant` and `AmazonS3CustomACL`

`AmazonS3ACLPermissionGrant` grants multiple users/user groups a single permission.
`AmazonS3CustomACL` is comprised of multiple `AmazonS3ACLPermissionGrant`s to create any series of permissions you would like to create.

#### Examples

To give all users read access to the bucket:

    let readPermission = AmazonS3ACLPermissionGrant(permission: .Read, grantee: .AllUsers)
    amazonS3Manager.setBucketACL(readPermission)
    
To give all users read access to the bucket, authenticated users write access to the bucket, and two users with a given E-mail Address and given User ID full control:

    let readPermission = AmazonS3ACLPermissionGrant(permission: .Read, grantee: .AllUsers)
    let writePermission = AmazonS3ACLPermissionGrant(permission: .Write, grantee: .AuthenticatedUsers)
    let fullControlPermission = AmazonS3ACLPermissionGrant(permission: .FullControl, grantees: [.EmailAddress("admin@myDomain.com"), .UserID("my-user-id")])
    let customACL = AmazonS3CustomACL(grants: [readPermission, writePermission, fullControlPermission])
    amazonS3Manager.setBucketACL(customACL)

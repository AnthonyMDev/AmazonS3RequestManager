# AmazonS3RequestManager
A Alamofire based request manager that serializes requests to the AWS S3 (Amazon Simple Storage Solution). Based on AFAmazonS3Manager

## Usage
First create an instance of the manager.

    let amazonS3Manager = AmazonS3RequestManager(bucket: AmazonS3Bucket,
        region: .USStandard,
        accessKey: AmazonS3AccessKey,
        secret: AmazonS3Secret)

### Get Objects

    let destination: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    amazonS3Manager.getObject("myFolder/fileName.jpg", saveToURL: destination)
    
### Upload Objects
    let fileURL: NSURL = NSURL(fileURLWithPath: "pathToMyObject")
    amazonS3Manager.putObject(fileURL, destinationPath: "pathToSaveObjectTo/fileName.jpg")
    
### Delete Objects

    amazonS3Manager.deleteObject("myFolder/fileName.jpg")

//
//  S3Error.swift
//  AmazonS3RequestManager
//
//  Created by Anthony Miller on 10/5/15.
//  Copyright © 2015 Anthony Miller. All rights reserved.
//

import Foundation

/**
 *  The error types that can be returned from a failed request to the Amazon S3 service.
 *
 *  :see: For more information on these errors, see `http://docs.aws.amazon.com/AmazonS3/latest/API/ErrorResponses.html`.
 */
public enum S3Error: String {
    
    /// The domain used for creating all AmazonS3RequestManager errors.
    public static let Domain = "com.AmazonS3RequestManager.error"
    
    case
    accessDenied = "AccessDenied",
    accountProblem = "AccountProblem",
    ambiguousGrantByEmailAddress = "AmbiguousGrantByEmailAddress",
    badDigest = "BadDigest",
    bucketAlreadyExists = "BucketAlreadyExists",
    bucketAlreadyOwnedByYou = "BucketAlreadyOwnedByYou",
    bucketNotEmpty = "BucketNotEmpty",
    credentialsNotSupported = "CredentialsNotSupported",
    crossLocationLoggingProhibited = "CrossLocationLoggingProhibited",
    entityTooSmall = "EntityTooSmall",
    entityTooLarge = "EntityTooLarge",
    expiredToken = "ExpiredToken",
    illegalVersioningConfigurationException = "IllegalVersioningConfigurationException",
    incompleteBody = "IncompleteBody",
    incorrectNumberOfFilesInPostRequest = "IncorrectNumberOfFilesInPostRequest",
    inlineDataTooLarge = "InlineDataTooLarge",
    internalError = "InternalError",
    invalidAccessKeyId = "InvalidAccessKeyId",
    invalidAddressingHeader = "InvalidAddressingHeader",
    invalidArgument = "InvalidArgument",
    invalidBucketName = "InvalidBucketName",
    invalidBucketState = "InvalidBucketState",
    invalidDigest = "InvalidDigest",
    invalidEncryptionAlgorithmError = "InvalidEncryptionAlgorithmError",
    invalidLocationConstraint = "InvalidLocationConstraint",
    invalidObjectState = "InvalidObjectState",
    invalidPart = "InvalidPart",
    invalidPartOrder = "InvalidPartOrder",
    invalidPayer = "InvalidPayer",
    invalidPolicyDocument = "InvalidPolicyDocument",
    invalidRange = "InvalidRange",
    invalidRequest = "InvalidRequest",
    invalidSecurity = "InvalidSecurity",
    invalidSOAPRequest = "InvalidSOAPRequest",
    invalidStorageClass = "InvalidStorageClass",
    invalidTargetBucketForLogging = "InvalidTargetBucketForLogging",
    invalidToken = "InvalidToken",
    invalidURI = "InvalidURI",
    keyTooLong = "KeyTooLong",
    malformedACL = "MalformedACLError",
    malformedPOSTRequest = "MalformedPOSTRequest",
    malformedXML = "MalformedXML",
    maxMessageLengthExceeded = "MaxMessageLengthExceeded",
    maxPostPreDataLengthExceeded = "MaxPostPreDataLengthExceededError",
    metadataTooLarge = "MetadataTooLarge",
    methodNotAllowed = "MethodNotAllowed",
    missingAttachment = "MissingAttachment",
    missingContentLength = "MissingContentLength",
    missingRequestBody = "MissingRequestBodyError",
    missingSecurityElement = "MissingSecurityElement",
    missingSecurityHeader = "MissingSecurityHeader",
    noLoggingStatusForKey = "NoLoggingStatusForKey",
    noSuchBucket = "NoSuchBucket",
    noSuchKey = "NoSuchKey",
    noSuchLifecycleConfiguration = "NoSuchLifecycleConfiguration",
    noSuchUpload = "NoSuchUpload",
    noSuchVersion = "NoSuchVersion",
    notImplemented = "NotImplemented",
    notSignedUp = "NotSignedUp",
    noSuchBucketPolicy = "NoSuchBucketPolicy",
    operationAborted = "OperationAborted",
    permanentRedirect = "PermanentRedirect",
    preconditionFailed = "PreconditionFailed",
    redirect = "Redirect",
    restoreAlreadyInProgress = "RestoreAlreadyInProgress",
    requestIsNotMultiPartContent = "RequestIsNotMultiPartContent",
    requestTimeout = "RequestTimeout",
    requestTimeTooSkewed = "RequestTimeTooSkewed",
    requestTorrentOfBucket = "RequestTorrentOfBucket",
    signatureDoesNotMatch = "SignatureDoesNotMatch",
    serviceUnavailable = "ServiceUnavailable",
    slowDown = "SlowDown",
    temporaryRedirect = "TemporaryRedirect",
    tokenRefreshRequired = "TokenRefreshRequired",
    tooManyBuckets = "TooManyBuckets",
    unexpectedContent = "UnexpectedContent",
    unresolvableGrantByEmailAddress = "UnresolvableGrantByEmailAddress",
    userKeyMustBeSpecified = "UserKeyMustBeSpecified"
    
    public var code: Int {
        switch self {
        default: return -9999
        }
    }
    
    func error(failureReason: String?) -> NSError {
        var userInfo: [String: AnyObject]? = nil
        if let failureReason = failureReason {
            userInfo = [NSLocalizedFailureReasonErrorKey: failureReason as AnyObject]
        }
        
        return NSError(domain: S3Error.Domain, code: self.code, userInfo: userInfo)
    }
    
}


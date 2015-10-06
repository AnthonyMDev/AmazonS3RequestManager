//
//  AmazonS3Error.swift
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
public enum AmazonS3Error: String, ErrorType {
  
  case AccessDenied = "AccessDenied",
  AccountProblem = "AccountProblem",
  AmbiguousGrantByEmailAddress = "AmbiguousGrantByEmailAddress",
  BadDigest = "BadDigest",
  BucketAlreadyExists = "BucketAlreadyExists",
  BucketAlreadyOwnedByYou = "BucketAlreadyOwnedByYou",
  BucketNotEmpty = "BucketNotEmpty",
  CredentialsNotSupported = "CredentialsNotSupported",
  CrossLocationLoggingProhibited = "CrossLocationLoggingProhibited",
  EntityTooSmall = "EntityTooSmall",
  EntityTooLarge = "EntityTooLarge",
  ExpiredToken = "ExpiredToken",
  IllegalVersioningConfigurationException = "IllegalVersioningConfigurationException",
  IncompleteBody = "IncompleteBody",
  IncorrectNumberOfFilesInPostRequest = "IncorrectNumberOfFilesInPostRequest",
  InlineDataTooLarge = "InlineDataTooLarge",
  InternalError = "InternalError",
  InvalidAccessKeyId = "InvalidAccessKeyId",
  InvalidAddressingHeader = "InvalidAddressingHeader",
  InvalidArgument = "InvalidArgument",
  InvalidBucketName = "InvalidBucketName",
  InvalidBucketState = "InvalidBucketState",
  InvalidDigest = "InvalidDigest",
  InvalidEncryptionAlgorithmError = "InvalidEncryptionAlgorithmError",
  InvalidLocationConstraint = "InvalidLocationConstraint",
  InvalidObjectState = "InvalidObjectState",
  InvalidPart = "InvalidPart",
  InvalidPartOrder = "InvalidPartOrder",
  InvalidPayer = "InvalidPayer",
  InvalidPolicyDocument = "InvalidPolicyDocument",
  InvalidRange = "InvalidRange",
  InvalidRequest = "InvalidRequest",
  InvalidSecurity = "InvalidSecurity",
  InvalidSOAPRequest = "InvalidSOAPRequest",
  InvalidStorageClass = "InvalidStorageClass",
  InvalidTargetBucketForLogging = "InvalidTargetBucketForLogging",
  InvalidToken = "InvalidToken",
  InvalidURI = "InvalidURI",
  KeyTooLong = "KeyTooLong",
  MalformedACL = "MalformedACLError",
  MalformedPOSTRequest = "MalformedPOSTRequest",
  MalformedXML = "MalformedXML",
  MaxMessageLengthExceeded = "MaxMessageLengthExceeded",
  MaxPostPreDataLengthExceeded = "MaxPostPreDataLengthExceededError",
  MetadataTooLarge = "MetadataTooLarge",
  MethodNotAllowed = "MethodNotAllowed",
  MissingAttachment = "MissingAttachment",
  MissingContentLength = "MissingContentLength",
  MissingRequestBody = "MissingRequestBodyError",
  MissingSecurityElement = "MissingSecurityElement",
  MissingSecurityHeader = "MissingSecurityHeader",
  NoLoggingStatusForKey = "NoLoggingStatusForKey",
  NoSuchBucket = "NoSuchBucket",
  NoSuchKey = "NoSuchKey",
  NoSuchLifecycleConfiguration = "NoSuchLifecycleConfiguration",
  NoSuchUpload = "NoSuchUpload",
  NoSuchVersion = "NoSuchVersion",
  NotImplemented = "NotImplemented",
  NotSignedUp = "NotSignedUp",
  NoSuchBucketPolicy = "NoSuchBucketPolicy",
  OperationAborted = "OperationAborted",
  PermanentRedirect = "PermanentRedirect",
  PreconditionFailed = "PreconditionFailed",
  Redirect = "Redirect",
  RestoreAlreadyInProgress = "RestoreAlreadyInProgress",
  RequestIsNotMultiPartContent = "RequestIsNotMultiPartContent",
  RequestTimeout = "RequestTimeout",
  RequestTimeTooSkewed = "RequestTimeTooSkewed",
  RequestTorrentOfBucket = "RequestTorrentOfBucket",
  SignatureDoesNotMatch = "SignatureDoesNotMatch",
  ServiceUnavailable = "ServiceUnavailable",
  SlowDown = "SlowDown",
  TemporaryRedirect = "TemporaryRedirect",
  TokenRefreshRequired = "TokenRefreshRequired",
  TooManyBuckets = "TooManyBuckets",
  UnexpectedContent = "UnexpectedContent",
  UnresolvableGrantByEmailAddress = "UnresolvableGrantByEmailAddress",
  UserKeyMustBeSpecified = "UserKeyMustBeSpecified"
  
}
//
//  Region.swift
//
//  Created by Anthony Miller on 1/17/17.
//  Copyright (c) 2017 App-Order, LLC. All rights reserved.
//

import Foundation

/**
 MARK: Amazon S3 Regions
 
 The possible Amazon Web Service regions for the client.
 
 - USStandard:   N. Virginia or Pacific Northwest
 - USWest1:      Oregon
 - USWest2:      N. California
 - EUWest1:      Ireland
 - EUCentral1:   Frankfurt
 - APSoutheast1: Singapore
 - APSoutheast2: Sydney
 - APNortheast1: Toyko
 - APNortheast2: Seoul
 - SAEast1:      Sao Paulo
 */
public enum Region: Equatable {
    
    case USStandard,
    USWest1,
    USWest2,
    EUWest1,
    EUCentral1,
    APSoutheast1,
    APSoutheast2,
    APNortheast1,
    APNortheast2,
    SAEast1,
    custom(hostName: String, endpoint: String)
    
    var hostName: String {
        switch self {
        case .USStandard: return "us-east-1"
        case .USWest1: return "us-west-1"
        case .USWest2: return "us-west-2"
        case .EUWest1: return "eu-west-1"
        case .EUCentral1: return "eu-central-1"
        case .APSoutheast1: return "ap-southeast-1"
        case .APSoutheast2: return "ap-southeast-2"
        case .APNortheast1: return "ap-northeast-1"
        case .APNortheast2: return "ap-northeast-2"
        case .SAEast1: return "sa-east-1"
        case .custom(let hostName, _): return hostName
        }
    }
    
    var endpoint: String {
        switch self {
        case .USStandard: return "s3.amazonaws.com"
        case .USWest1: return "s3-us-west-1.amazonaws.com"
        case .USWest2: return "s3-us-west-2.amazonaws.com"
        case .EUWest1: return "s3-eu-west-1.amazonaws.com"
        case .EUCentral1: return "s3-eu-central-1.amazonaws.com"
        case .APSoutheast1: return "s3-ap-southeast-1.amazonaws.com"
        case .APSoutheast2: return "s3-ap-southeast-2.amazonaws.com"
        case .APNortheast1: return "s3-ap-northeast-1.amazonaws.com"
        case .APNortheast2: return "s3-ap-northeast-2.amazonaws.com"
        case .SAEast1: return "s3-sa-east-1.amazonaws.com"
        case .custom(_, let endpoint): return endpoint
        }
    }
}

public func ==(lhs: Region, rhs: Region) -> Bool {
    switch (lhs, rhs) {
        case (.USStandard, .USStandard),
             (.USWest1, .USWest1),
             (.USWest2, .USWest2),
             (.EUWest1, .EUWest1),
             (.EUCentral1, .EUCentral1),
             (.APSoutheast1, .APSoutheast1),
             (.APSoutheast2, .APSoutheast2),
             (.APNortheast1, .APNortheast1),
             (.APNortheast2, .APNortheast2),
             (.SAEast1, .SAEast1):
        return true
        
    case (.custom(let host1, let endpoint1), .custom(let host2, let endpoint2)):
        return host1 == host2 && endpoint1 == endpoint2
        
    default:
        return false
    }
}

//
//  File.swift
//  
//
//  Created by Matias Piipari on 22.11.2020.
//

import Foundation
import CryptoSwift

enum SigningError: Error {
    case noURL
    case nonBase64EncodableSignature
}

func signature(forRequest request: URLRequest, timestamp: String, secret key: String) throws -> String {
    return try signature(forRequest: request,
                         headerValues: canonicalizedHeaderValues(request: request),
                         timestamp: timestamp,
                         secret: key)
}

private func signature(forRequest request: URLRequest,
               headerValues: [String: String],
               timestamp: String,
               secret key: String) throws -> String {
    guard let url = request.url else {
        throw SigningError.noURL
    }
    let method = request.httpMethod
    let contentMD5 = request.value(forHTTPHeaderField: "Content-MD5")
    let contentType = request.value(forHTTPHeaderField: "Content-Type")

    var payload = ""
    payload.append(method ?? "")
    payload.append("\n")
    payload.append(contentMD5 ?? "")
    payload.append("\n")
    payload.append(contentType ?? "")
    payload.append("\n")
    payload.append(timestamp)
    payload.append("\n")
    payload.append(canonicalizedHeaderString(headerFields: headerValues))
    payload.append(canonicalizedResource(from: url))

    return try base64EncodedHMACSHA1(key: key, payload: payload)
}

func canonicalizedHeaderValues(request: URLRequest) -> [String: String] {
    let origHeaderFields = request.allHTTPHeaderFields ?? [String: String]()
    var canonicalized = [String: String]()

    for (field, value) in origHeaderFields {
        let field = field.lowercased()
        var value = value
        if field.hasPrefix("x-amz") {
            if let headerValue = canonicalized[field] {
                value = headerValue.appending(",\(value)")
            }
            canonicalized[field] = value
        }
    }
    return canonicalized
}

func canonicalizedHeaderString(headerFields: [String: String]) -> String {
    var output = ""
    for field in headerFields.keys.sorted() {
        guard let value = headerFields[field] else {
            preconditionFailure("Header value unexpectedly missing")
        }
        output.append("\(field):\(value)\n")
    }
    return output
}


func canonicalizedResource(from url: URL) -> String {
    return url.path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
}

func base64EncodedHMACSHA1(key: String, payload: String) throws -> String {
    let hmac = try HMAC(key: key, variant: .sha1)
    let base64Encoded = try hmac.authenticate(payload.bytes).toBase64()
    return base64Encoded
}

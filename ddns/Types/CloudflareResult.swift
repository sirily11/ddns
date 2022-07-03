//
//  CloudflareResult.swift
//  ddns
//
//  Created by Qiwei Li on 7/2/22.
//

import Foundation

protocol CloudflareCodableResult: Codable {
    
}


struct CloudflareResult<T: CloudflareCodableResult>: Codable {
    var success: Bool
    var errors: [CloudflareError]
    var result: T?
    
    func with(error: CloudflareErrorCode) -> Bool {
        for err in errors {
            if err.code == error {
                return true
            }
        }
        return false
    }
}

// MARK: - CloudflareDNSCreationParameter
struct CloudflareDNSCreationParameter: Codable {
    var type: String
    var name, content: String
    var proxied: Bool
}


// MARK: - Error
struct CloudflareError: Codable {
    var code: CloudflareErrorCode
    var message: String
}


// MARK: - CloudflareDNSResult
struct CloudflareDNSResult: CloudflareCodableResult {
    var id, type, name, content: String
}

// MARK: - Meta
struct Meta: Codable {
    var autoAdded: Bool
    var source: String
}

enum CloudflareErrorCode: Int, Codable {
    case alreadyExist = 81057
    case authorizationError = 10000
    case unauthorizedToAccessResource = 9109
    case noRoute = 7000
    
}

// MARK: - CloudflareZoneDetail
struct CloudflareZoneDetailResult: CloudflareCodableResult {
    var id, name, status: String
}

// MARK: - Plan
struct Plan: Codable {
    var id, name: String
    var price: Int
    var currency, frequency: String
    var isSubscribed, canSubscribe: Bool
    var legacyID: String
    var legacyDiscount, externallyManaged: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, price, currency, frequency
        case isSubscribed
        case canSubscribe
        case legacyID
        case legacyDiscount
        case externallyManaged
    }
}

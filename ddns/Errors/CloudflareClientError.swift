//
//  InvalidHostError.swift
//  ddns
//
//  Created by Qiwei Li on 7/2/22.
//

import Foundation

enum InvalidHostError: Error {
    case notInit
}

enum CloudflareClientError: Error {
    case creationError(reason: String)
    case updateError(reason: String)
    case deletionError(reason: String)
    case retrieveError(reason: String)
}

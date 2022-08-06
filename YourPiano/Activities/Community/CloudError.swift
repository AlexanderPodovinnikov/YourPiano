//
//  CloudError.swift
//  YourPiano
//
//  Created by Alex Po on 05.08.2022.
//
import CloudKit
import Foundation

/// Identifiable clear error message
struct CloudError: Identifiable, ExpressibleByStringInterpolation {
    var id: String { message }
    private(set) var message: String

    init(stringLiteral value: String) {
        self.message = value
    }

    init(_ error: Error) {
        guard let error = error as? CKError else {
            message = "UNKNOWN_ERROR \(error.localizedDescription)"
            return
        }
        switch error.code {
        case .badDatabase, .badContainer, .invalidArguments:
            message = "FATAL_ERROR \(error.localizedDescription)"
        case .networkFailure, .networkUnavailable, .serverResponseLost, .serviceUnavailable:
            message = "COMMUNICATION_ERROR"
        case .notAuthenticated:
            message = "AUTHENTICATION_ERROR"
        case .requestRateLimited:
            message = "RATE_LIMIT_ERROR"
        case .quotaExceeded:
            message = "QUOTA_ERROR"

        default:
            message = "UNKNOWN_ERROR \(error.localizedDescription)"
        }
    }
}

//  !!! Deprecated !!!
//  Error-CloudKitMessages.swift
//  YourPiano
//
//  Created by Alex Po on 05.08.2022.
//

import CloudKit
import Foundation

extension Error {
    /// Returns CloudKit errors in more convenient and clear form.
    ///
    /// Method will be deleted
    /// - Returns: Error message, wrapped in Identifiable struct CloudError.
    func getCloudKitError() -> CloudError {
        guard let error = self as? CKError else {
            return "UNKNOWN_ERROR \(self.localizedDescription)"
        }
        switch error.code {
        case .badDatabase, .badContainer, .invalidArguments:
            return "FATAL_ERROR \(error.localizedDescription)"
        case .networkFailure, .networkUnavailable, .serverResponseLost, .serviceUnavailable:
            return "COMMUNICATION_ERROR"
        case .notAuthenticated:
            return "AUTHENTICATION_ERROR"
        case .requestRateLimited:
            return "RATE_LIMIT_ERROR"
        case .quotaExceeded:
            return "QUOTA_ERROR"

        default:
            return "UNKNOWN_ERROR \(self.localizedDescription)"
        }
    }
}

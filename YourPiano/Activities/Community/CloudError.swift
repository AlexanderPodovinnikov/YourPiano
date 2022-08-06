//
//  CloudError.swift
//  YourPiano
//
//  Created by Alex Po on 05.08.2022.
//

import Foundation

/// Identifiable error message
struct CloudError: Identifiable, ExpressibleByStringInterpolation {
    var id: String { message }
    var message: String

    init(stringLiteral value: String) {
        self.message = value
    }
}

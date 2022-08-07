//
//  SharedItem.swift
//  YourPiano
//
//  Created by Alex Po on 31.07.2022.
//

import Foundation

/// An item, loaded from iCloud
struct SharedItem: Identifiable {
        let id: String
        let title: String
        let detail: String
        let completed: Bool
}

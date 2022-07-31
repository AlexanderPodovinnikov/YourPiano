//
//  SharedProject.swift
//  YourPiano
//
//  Created by Alex Po on 31.07.2022.
//

import Foundation

/// A project, loaded from iCloud.
struct SharedProject: Identifiable {
    let id: String
    let title: String
    let detail: String
    let owner: String
    let closed: Bool

    static let example = SharedProject(id: "1", title: "example", detail: "Some detail", owner: "AlexPo", closed: false)
}

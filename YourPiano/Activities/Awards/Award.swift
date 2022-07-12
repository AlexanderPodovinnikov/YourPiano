//
//  Award.swift
//  YourPiano
//
//  Created by Alex Po on 04.07.2022.
//

import Foundation

/// An entity for decoded awards from .json file
struct Award: Decodable, Identifiable {
    var id: String { name }
    let name: String
    let description: String
    let color: String
    let criterion: String
    let value: Int
    let image: String

    static let allAwards: [Award] = Bundle.main.decode([Award].self, from: "Awards.json")
    /// An example for previewing
    static let example = allAwards[0]
}

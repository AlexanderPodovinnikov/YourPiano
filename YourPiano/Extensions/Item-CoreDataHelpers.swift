//
//  Item-CoreDataHelpers.swift
//  YourPiano
//
//  Created by Alex Po on 29.06.2022.
//

import Foundation

extension Item {

    /// Available sorting rules: by priority and creation date, by creation date only, and by title
    enum SortOrder {
        case optimized, creationDate, title
    }

    /// Wrapper for optional item attribute Title
    var itemTitle: String {
        title ?? NSLocalizedString("New Item", comment: "Create a new item")
    }

    /// Wrapper for optional item attribute Detail
    var itemDetail: String {
        detail ?? ""
    }

    /// Wrapper vor optional item attribute CreationDate
    var itemCreationDate: Date {
        creationDate ?? Date()
    }

    /// Data for preview purposes
    static var example: Item {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let item = Item(context: viewContext)
        item.title = "Example Item"
        item.detail = "This is an example"
        item.priority = 3
        item.creationDate = Date()

        return item
    }
}

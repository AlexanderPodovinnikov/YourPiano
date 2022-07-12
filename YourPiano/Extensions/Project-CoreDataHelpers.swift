//
//  Project-CoreDataHelpers.swift
//  YourPiano
//
//  Created by Alex Po on 29.06.2022.
//

import SwiftUI

extension Project {

    /// Wrapper for optional project attribute Title.
    var projectTitle: String {
        title ?? NSLocalizedString("New Section", comment: "Create a new section")
    }

    /// Wrapper for optional project attribute Detail.
    var projectDetail: String {
        detail ?? ""
    }

    /// Wrapper for optional project attribute Color.
    var projectColor: String {
        color ?? "Light Blue"
    }

    /// Wrapper for optional project attribute Items (set of project items).
    var projectItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }

    /// Array of project items that is sorted i default order: by completion, priority, and creation date.
    var projectItemsDefaultSorted: [Item] {
        projectItems.sorted { first, second in
            if !first.completed {
                if second.completed {
                    return true
                }
            } else if first.completed {
                if !second.completed {
                    return false
                }
            }
            if first.priority > second.priority {
                return true
            } else if first.priority < second.priority {
                return false
            }
            return first.itemCreationDate < second.itemCreationDate
        }
    }

    /// Percentage of completed project's items.
    var completionAmount: Double {
        let originalItems = items?.allObjects as? [Item] ?? []
        guard originalItems.isEmpty == false else { return 0 }
        let completedItems = originalItems.filter(\.completed)
        return Double(completedItems.count) / Double(originalItems.count)
    }

    /// Data for previewing purposes.
    static var example: Project {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let project = Project(context: viewContext)
        project.title = "Example Section"
        project.detail = "This is an example"
        project.closed = true
        project.creationDate = Date()

        return project
    }

    /// Accessibility label text for project summary.
    var label: LocalizedStringKey {
        LocalizedStringKey(
            "\(projectTitle), \(projectItems.count) items, \(completionAmount * 100, specifier: "%g")% complete."
        )
    }

    /// Array of custom project colors.
    static let colors = [
        "Pink",
        "Purple",
        "Red",
        "Orange",
        "Gold",
        "Green",
        "Teal",
        "Light Blue",
        "Dark Blue",
        "Midnight",
        "Dark Gray",
        "Gray"
    ]

    /// Sorts items in specified order
    /// - Parameter sortOrder: SortOrder enum case that sets the sort order.
    /// - Returns: Sorted array of project's  items.
    func projectItems(using sortOrder: Item.SortOrder) -> [Item] {
        switch sortOrder {
        case .optimized:
            return projectItemsDefaultSorted
        case .creationDate:
            return projectItems.sorted(by: \Item.itemCreationDate)
        case .title:
            return projectItems.sorted(by: \Item.itemTitle)
        }
    }
}

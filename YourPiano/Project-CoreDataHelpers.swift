//
//  Project-CoreDataHelpers.swift
//  YourPiano
//
//  Created by Alex Po on 29.06.2022.
//

import Foundation

extension Project {
    var projectTitle: String {
        title ?? ""
    }
    
    var projectDetail: String {
        detail ?? ""
    }
    
    var projectColor: String {
        color ?? "Light Blue"
    }
    
    var projectItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }
    
    var projectItemsDefaultSorted: [Item] {
//        let itemsArray = items?.allObjects as? [Item] ?? []
//        return itemsArray.sorted { first, second in
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
    
    var completionAmount: Double {
        let originalItems = items?.allObjects as? [Item] ?? []
        guard originalItems.isEmpty == false else { return 0 }
        let completedItems = originalItems.filter(\.completed)
        return Double(completedItems.count) / Double(originalItems.count)
    }
    
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
    
    static let colors = ["Pink", "Purple", "Red", "Orange", "Gold", "Green", "Teal", "Light Blue", "Dark Blue", "Midnight", "Dark Gray", "Gray"]
    
    func projectItems<Value: Comparable>(sortedBy keyPath: KeyPath<Item, Value>) -> [Item] {
        projectItems.sorted {
            $0[keyPath: keyPath] < $1[keyPath: keyPath]
        }
    }
}

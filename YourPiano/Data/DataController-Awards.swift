//
//  DataController-Awards.swift
//  YourPiano
//
//  Created by Alex Po on 28.07.2022.
//

import Foundation
import CoreData

extension DataController {
    /// Checks if user has earned the award.
    /// - Parameter award: The award to check
    /// - Returns: True if the award was earned, or false - if not.
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {

        case "items":
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "complete":
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        default:
            return false
        }
    }
}

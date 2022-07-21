//
//  ItemRowViewModel.swift
//  YourPiano
//
//  Created by Alex Po on 21.07.2022.
//

import Foundation

extension ItemRowView {
    class ViewModel: ObservableObject {
        let project: Project
        let item: Item

        /// label for accessibility text
        var itemLabel: String {
            if item.completed {
                return "\(item.itemTitle), completed."
            } else if item.priority == 3 {
                return "\(item.itemTitle), high priority."
            } else {
                return item.itemTitle
            }
        }

        /// Icon system name for the item
        var icon: String {
            if item.completed {
                return "checkmark.circle"
            } else if item.priority == 3 {
                return "exclamationmark.triangle"
            } else {
                return "checkmark.circle"
            }
        }

        /// Icon color for the Item
        var color: String? {
            if item.completed {
                return project.projectColor
            } else if item.priority == 3 {
                return project.projectColor
            } else {
                return nil
            }
        }

        var title: String {
            item.itemTitle
        }

        init(project: Project, item: Item) {
            self.project = project
            self.item = item
        }

    }
}

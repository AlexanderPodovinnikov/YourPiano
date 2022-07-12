//
//  ItemRowView.swift
//  YourPiano
//
//  Created by Alex Po on 30.06.2022.
//

import SwiftUI

// All this stuff is needed for having an @ObservedObject
// - that forces the View to refresh when objectWillChange event occurs

/// View that presents item in ProjectView and listens
/// for changes to the  item's attributes to reflect them immediately.
struct ItemRowView: View {
    @ObservedObject var project: Project
    @ObservedObject var item: Item

    /// label for accessibility text
    var itemLabel: Text {
        if item.completed {
            return Text("\(item.itemTitle), completed.")
        } else if item.priority == 3 {
            return Text("\(item.itemTitle), high priority.")
        } else {
            return Text(item.itemTitle)
        }
    }

    var icon: some View {
        if item.completed {
            return Image(systemName: "checkmark.circle")
                        .foregroundColor(Color(project.projectColor))
        } else if item.priority == 3 {
            return Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(Color(project.projectColor))
        } else {
            return Image(systemName: "checkmark.circle")
                .foregroundColor(.clear)
        }

    }

    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(item.itemTitle)
            } icon: {
                icon
            }

        }
        .accessibilityLabel(itemLabel)
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(project: Project.example, item: Item.example)
    }
}

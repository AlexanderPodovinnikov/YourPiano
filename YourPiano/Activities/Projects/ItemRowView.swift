//
//  ItemRowView.swift
//  YourPiano
//
//  Created by Alex Po on 30.06.2022.
//

import SwiftUI

// All this stuff is needed for having an @ObservedObject
// - that forces the View to refresh when objectWillChange event occurs????

/// View that presents item in ProjectView and listens
/// for changes to the  item's attributes to reflect them immediately.
struct ItemRowView: View {
    @StateObject var viewModel: ViewModel
    @ObservedObject var item: Item

    init(project: Project, item: Item) {
        let viewModel = ViewModel(project: project, item: item)
        _viewModel = StateObject(wrappedValue: viewModel)

        self.item = item
    }

    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(viewModel.title)
            } icon: {
                Image(systemName: viewModel.icon)
// we can’t convert an optional string into a Color directly –
// that initializer doesn’t exist. So we have to use optional map
                    .foregroundColor(
                        viewModel.color.map { Color($0) } ?? .clear
                    )
            }
        }
        .accessibilityLabel(viewModel.itemLabel)
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(project: Project.example, item: Item.example)
    }
}

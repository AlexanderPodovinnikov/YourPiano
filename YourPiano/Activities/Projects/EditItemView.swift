//
//  EditItemView.swift
//  YourPiano
//
//  Created by Alex Po on 29.06.2022.
//

import SwiftUI

/// Form to edit item attributes.
struct EditItemView: View {
    @EnvironmentObject var dataController: DataController
    let item: Item

    /// Item title
    @State private var title: String
    /// Item detail
    @State private var detail: String
    /// Item priority
    @State private var priority: Int
    /// Item completed attribute
    @State private var completed: Bool

    init(item: Item) {
        self.item = item
        _title = State(wrappedValue: item.itemTitle)
        _detail = State(wrappedValue: item.itemDetail)
        _priority = State(wrappedValue: Int(item.priority))
        _completed = State(wrappedValue: item.completed)
    }

    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Item name", text: $title.onChange(update))
                TextField("Description", text: $detail.onChange(update))
            }
            Section(header: Text("Priority")) {
                Picker("Priority", selection: $priority.onChange(update)) {
                    Text("Low").tag(1)
                    Text("Medium").tag(2)
                    Text("High").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section {
                Toggle(isOn: $completed.onChange(update)) {
                    Text("Mark Completed")
                }
            }
            MacOnlySpacer()
        }
        .navigationTitle("Edit Item")
        .onDisappear(perform: save)
        .macOnlyPadding()
    }
    /// Updates item's title, detail, priority and completed attribute to their actual values.
    func update() {
        item.project?.objectWillChange.send()
        item.title = title
        item.detail = detail
        item.priority = Int16(priority)
        item.completed = completed
    }
    // We only have to call the dataController.update method once -
    // when we're about to finish editing an item, so we don't re-index items
    // as soon as they changed a single character on the screen.
    func save() {
        dataController.update(item)
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {
        EditItemView(item: Item.example)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}

//
//  SharedItemsView.swift
//  YourPiano
//
//  Created by Alex Po on 01.08.2022.
//

import SwiftUI
import CloudKit

struct SharedItemsView: View {
    let project: SharedProject

    @State private var items = [SharedItem]()
    @State private var loadState = LoadState.inactive

    var body: some View {
        List {
            Section {
                switch loadState {
                case .inactive, .loading:
                    ProgressView()
                case .noResults:
                    Text("NO_RESULTS")
                case .success:
                    ForEach(items) {item in
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)
                            if item.detail.isEmpty == false {
                                Text(item.detail)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(project.title)
        .onAppear(perform: fetchSharedItems)
    }

    func fetchSharedItems() {
        guard loadState == .inactive else { return }
        loadState = .loading

        let recordID = CKRecord.ID(recordName: project.id) // current project ref ID
        let reference = CKRecord.Reference(recordID: recordID, action: .none)

        let predicate = NSPredicate(format: "project == %@", reference)
        let sortOrder = NSSortDescriptor(key: "title", ascending: true)
        let query = CKQuery(recordType: "Item", predicate: predicate)
        query.sortDescriptors = [sortOrder]

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "detail", "completed"]
        operation.resultsLimit = 50

        operation.recordMatchedBlock = { _, recordResult in
            if let record = try? recordResult.get() {
                let id = record.recordID.recordName
                let title = record["title"] as? String ?? "No title"
                let detail = record["detail"] as? String ?? ""
                let completed = record["completed"] as? Bool ?? false

                let sharedItem = SharedItem(
                    id: id,
                    title: title,
                    detail: detail,
                    completed: completed
                )
                items.append(sharedItem)
                loadState = .success
            } else if case .failure(let error) = recordResult {
                print("Failed load record \(error.localizedDescription)")
            }
        }
        operation.queryResultBlock = { _ in
            if items.isEmpty {
                loadState = .noResults
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }
}

struct SharedItemsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedItemsView(project: SharedProject.example)
    }
}

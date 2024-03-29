//
//  SharedProjectsView.swift
//  YourPiano
//
//  Created by Alex Po on 31.07.2022.
//

import SwiftUI
import CloudKit

struct SharedProjectsView: View {
    static let tag: String? = "Community"

    @State private var projects = [SharedProject]()
    @State private var loadState = LoadState.inactive
    @State private var cloudError: CloudError?

    var body: some View {
        NavigationView {
            Group {
                switch loadState {
                case .inactive, .loading:
                    ProgressView()
                case .noResults:
                    Text("NO_RESULTS")
                case .success:
                    List(projects) { project in
                        NavigationLink(destination: SharedItemsView(project: project)) {
                            VStack(alignment: .leading) {
                                Text(project.title)
                                    .font(.headline)
                                Text(project.owner)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("SHARED_PROJECTS")
            .toolbar(content: {
                Button(action: synchronize) {
                    Label("SYNCHRONIZE", systemImage: "arrow.clockwise.icloud")
                }
            })
            .alert(item: $cloudError) { error in
                Alert(
                    title: Text("ERROR_ALERT"),
                    message: Text(error.localizedMessage)
                )
            }
        }
        .onAppear(perform: fetchSharedProjects)
    }

    func fetchSharedProjects() {
        guard loadState == .inactive else { return }
        loadState = .loading

        let predicate = NSPredicate(value: true)
        let sortOrder = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Project", predicate: predicate)
        query.sortDescriptors = [sortOrder]

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "detail", "owner", "closed"]
        operation.resultsLimit = 50

        operation.recordMatchedBlock = { recordID, recordResult in

            switch recordResult {

            case .failure(let error):
//                cloudError = error.getCloudKitError()
                cloudError = CloudError(error)

            case .success(let record):
                let id = record.recordID.recordName
                let title = record["title"] as? String ?? "No title"
                let detail = record["detail"] as? String ?? ""
                let owner = record["owner"] as? String ?? "No owner"
                let closed = record["closed"] as? Bool ?? false

                let sharedProject = SharedProject(
                    id: id,
                    title: title,
                    detail: detail,
                    owner: owner,
                    closed: closed
                )
                projects.append(sharedProject)
                loadState = .success
            }
        }
        operation.queryResultBlock = { _ in
            if projects.isEmpty {
                loadState = .noResults
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    /// Syncronizes view with actual cloud data.
    func synchronize() {
        projects = []
        loadState = .inactive
        fetchSharedProjects()
    }
}

struct SharedProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedProjectsView()
    }
}

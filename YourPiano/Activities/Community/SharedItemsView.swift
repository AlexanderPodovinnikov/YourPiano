//
//  SharedItemsView.swift
//  YourPiano
//
//  Created by Alex Po on 01.08.2022.
//

import SwiftUI
import CloudKit

struct SharedItemsView: View {

    @AppStorage("username") var username: String?

    /// Counter for user messages
    @AppStorage("chatCount") var chatCount = 0

    /// A Project, that was loaded from Cloud to investigate its items and comments
    let project: SharedProject

    @State private var cloudError: CloudError?
    @State private var items = [SharedItem]()
    @State private var itemsLoadState = LoadState.inactive
    @State private var messagesLoadState = LoadState.inactive
    @State private var messages = [ChatMessage]()
    @State private var showingSignIn = false
    @State private var newChatText = ""

    @ViewBuilder var messagesFooter: some View {
        if username == nil {
            Button("SIGN_IN_BTN", action: signIn)
                .frame(maxWidth: .infinity)
        } else {
            VStack {
                TextField("MESSAGE_PROMPT", text: $newChatText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textCase(nil)
                Button(action: sendChatMessage) {
                    Text("SEND_BTN")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                }
            }
        }
    }

    var body: some View {
        List {
            Section {
                switch itemsLoadState {
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
            Section(
                header: Text("CHAT_ABOUT"),
                footer: messagesFooter
            ) {
                ForEach(messages) { message in
                    Text("\(Text(message.from).bold()): \(message.text)")
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(project.title)
        .onAppear {
            fetchSharedItems()
            fetchChatMessages()
        }
        .sheet(isPresented: $showingSignIn, content: SignInView.init)
        .alert(item: $cloudError) { error in
            Alert(
                title: Text("ERROR_ALERT"),
                message: Text(error.localizedMessage)
            )
        }
    }

    func fetchSharedItems() {
        guard itemsLoadState == .inactive else { return }
        itemsLoadState = .loading

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
                itemsLoadState = .success
            }
        }
        operation.queryResultBlock = { result in
            if case .failure(let error) = result {
                cloudError = CloudError(error)
            }
            if items.isEmpty {
                itemsLoadState = .noResults
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    func fetchChatMessages() {
        guard messagesLoadState == .inactive else { return }
        messagesLoadState = .loading

        let recordID = CKRecord.ID(recordName: project.id) // current project ref ID
        let reference = CKRecord.Reference(recordID: recordID, action: .none)

        let predicate = NSPredicate(format: "project == %@", reference)
        let sortOrder = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "Message", predicate: predicate)
        query.sortDescriptors = [sortOrder]

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["from", "text"]

        operation.recordMatchedBlock = { _, recordResult in
            if let record = try? recordResult.get() {
                let message = ChatMessage(from: record)
                messages.append(message)
                messagesLoadState = .success
            }
        }
        operation.queryResultBlock = { result in
            if case .failure(let error) = result {
                cloudError = CloudError(error)
            }
            if messages.isEmpty {
                messagesLoadState = .noResults
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    func signIn() {
        showingSignIn = true
    }

    func sendChatMessage() {
        let text = newChatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count > 2 else { return }
        guard let username = username else { return }

        let message = CKRecord(recordType: "Message")
        message["from"] = username
        message["text"] = text
        let projectID = CKRecord.ID(recordName: project.id)
        message["project"] = CKRecord.Reference(recordID: projectID, action: .deleteSelf)

        let backupChatText = newChatText
        newChatText = ""
        CKContainer.default().publicCloudDatabase.save(message) { record, error in
            if let error = error {
                cloudError = CloudError(error)
                newChatText = backupChatText
            } else if let record = record {
                let newMessage = ChatMessage(from: record)
                messages.append(newMessage)
                chatCount += 1
            }
        }
    }
}

struct SharedItemsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedItemsView(project: SharedProject.example)
    }
}

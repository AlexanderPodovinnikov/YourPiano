//
//  ChatMessage.swift
//  YourPiano
//
//  Created by Alex Po on 04.08.2022.
//

import CloudKit

struct ChatMessage: Identifiable {
    let id: String
    let from: String
    let text: String
    let date: Date

}

// This will save the default initializer Swift generated for us
extension ChatMessage {
    init(from record: CKRecord) {
        id = record.recordID.recordName
        from = record["from"] as? String ?? "No author"
        text = record["text"] as? String ?? "No text"
        date = record.creationDate ?? Date()
    }
}

//
//  YourPianoApp.swift
//  YourPiano
//
//  Created by Alex Po on 28.06.2022.
//

import SwiftUI

@main
struct YourPianoApp: App {
    @StateObject var dataController: DataController
    
    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification), perform: save) // save all data when moved to background
        }
    }
    
    func save(_ note: Notification) {
        dataController.save()
    }
}

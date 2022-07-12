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

            // Save all data when moved to background!
            // Use this rather than
            // scene phase so we can port to macOS, where scene
            // phase won't detect our app losing focus.
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIApplication.willResignActiveNotification
                    ),
                    perform: save
                )
        }
    }

    func save(_ note: Notification) {
        dataController.save()
    }
}

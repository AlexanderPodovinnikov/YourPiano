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
    @StateObject var unlockManager: UnlockManager
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // needs more digging

// We need two StateObjects, one of which depends on the other,
// so we only have one way to do this - in an initializer.

    init() {
        let dataController = DataController()
        let unlockManager = UnlockManager(dataController: dataController)

        _dataController = StateObject(wrappedValue: dataController)
        _unlockManager = StateObject(wrappedValue: unlockManager)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(unlockManager)

            // Saves all data when moved to background!
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

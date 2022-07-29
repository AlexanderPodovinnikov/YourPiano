//
//  AppDelegate.swift
//  YourPiano
//
//  Created by Alex Po on 27.07.2022.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(
            name: "Default", sessionRole: connectingSceneSession.role
            )

        sceneConfiguration.delegateClass = SceneDelegate.self

        return sceneConfiguration
    }
}

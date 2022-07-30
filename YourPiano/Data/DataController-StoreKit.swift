//
//  DataController-StoreKit.swift
//  YourPiano
//
//  Created by Alex Po on 30.07.2022.
//

import StoreKit

extension DataController {
// Wonder if it works
    func appLaunched() {
        guard count(for: Project.fetchRequest()) >= 5 else { return }

        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        if let windowScene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

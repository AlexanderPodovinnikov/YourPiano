//
//  DataController-RequestReview.swift
//  YourPiano
//
//  Created by Alex Po on 27.07.2022.
//

import StoreKit

// Doesn't work. More digging required.
extension DataController {

    /// Finds the first active scene, then asking for a review prompt to appear there
    func appLaunched() {

        // API expects to be given the current UIWindowScene, so we’ll find all the scenes
        // that are active right now, convert the first to be a UIWindowScene,
        // then use that to show a review. A bit of hack, to be honest.
        let allScenes = UIApplication.shared.connectedScenes                    // Can't find any!
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        if let windowScene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
            print("!!!!!!! review request done !!!!!!!")
        } else {
            print("!!!!!!! failed to request review !!!!!!!!!!")
        }
    }
}

//
//  AwardsViewModel.swift
//  YourPiano
//
//  Created by Alex Po on 21.07.2022.
//

import Foundation

extension AwardsView {
    class ViewModel: ObservableObject {
        let dataController: DataController

        init(dataController: DataController) {
            self.dataController = dataController
        }

        func color(for award: Award) -> String? {
            dataController.hasEarned(award: award) ? award.color : nil
        }

        func label(for award: Award) -> String {
            dataController.hasEarned(award: award) ? "Unlocked" : "Locked"
        }

        func hasEarned(award: Award) -> Bool {
            dataController.hasEarned(award: award)
        }
    }
}

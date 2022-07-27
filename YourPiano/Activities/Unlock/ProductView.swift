//
//  ProductView.swift
//  YourPiano
//
//  Created by Alex Po on 25.07.2022.
//

import SwiftUI
import StoreKit

struct ProductView: View {
    @EnvironmentObject var unlockManager: UnlockManager
    /// Product to buy or restore.
    let product: SKProduct

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("GET_UNLIMITED")
                    .font(.headline)
                    .padding(.top, 10)
                Text("GET_THREE_OR_PAY \(product.localizedPrice)")
                Text("RESTORE_MSG")

                Button("BUY \(product.localizedPrice)", action: unlock)
                    .buttonStyle(PurchaseButton())
                Button("RESTORE_BTN", action: unlockManager.restore)
                    .buttonStyle(PurchaseButton())
            }
        }
    }

    private func unlock() {
        unlockManager.buy(product: product)
    }
}

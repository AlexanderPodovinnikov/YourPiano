//
//  UnlockView.swift
//  YourPiano
//
//  Created by Alex Po on 25.07.2022.
//

import StoreKit
import SwiftUI

struct UnlockView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var unlockManager: UnlockManager

    var body: some View {
        VStack {
            switch unlockManager.requestState {
            // If the store is loaded, we’ll read the product out and pass it into a ProductView
            case .loaded(let product):
                ProductView(product: product)
                // swiftlint:disable:next: empty_enum_arguments
            case .failed(_):
                Text("ERROR_MSG")
            case .loading:
                ProgressView("LOADING_MSG")
            case .purchased:
                Text("TNX_MSG")
            case .deferred:
                Text("PENDING_MSG")
            }
            Button("DISMISS", action: dismiss)
        }
        .padding()
        // Make the store to dismiss itself as soon as a purchase is successful
        .onReceive(unlockManager.$requestState) { value in
            if case .purchased = value {
                dismiss()
            }
        }
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

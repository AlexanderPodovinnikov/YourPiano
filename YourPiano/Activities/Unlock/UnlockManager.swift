//
//  UnlockManager.swift
//  YourPiano
//
//  Created by Alex Po on 24.07.2022.
//

import Combine
import StoreKit

class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    enum RequestState {
        case loading
        case loaded(SKProduct)
        case failed(Error?)
        case purchased
        case deferred
    }

    @Published var requestState = RequestState.loading

    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }

    private let dataController: DataController
    private let request: SKProductsRequest
    private var loadedProducts = [SKProduct]()

    private enum StoreError: Error {
        case invalidIdentifiers, missingProduct
    }

    init(dataController: DataController) {
        self.dataController = dataController

        let productIDs = Set(["com.Po.Alex.YourPiano.unlock"])
        request = SKProductsRequest(productIdentifiers: productIDs)

        // Because we inherit from NSObject
        super.init()
        // Start watching the payment queue
        SKPaymentQueue.default().add(self)

        // Do nothing if the app is already unlocked
        guard dataController.fullVersionUnlocked == false else {
            return
        }

        // Set ourselves up to be notified when the product request completes
        request.delegate = self

        // Start the request
        request.start()
    }

// We should make sure to remove our object from the payment queue observer
// when our application is being terminated, just to avoid any problems where
// iOS thinks our app has been notified about a purchase when really it wasn’t

    deinit {
        SKPaymentQueue.default().remove(self)
    }
    // Required by protocol
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [self] in

            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    self.dataController.fullVersionUnlocked = true
                    self.requestState = .purchased
                    queue.finishTransaction(transaction)

                case .failed:
                    if let product = loadedProducts.first {
                        self.requestState = .loaded(product)
                    } else {
                        self.requestState = .failed(transaction.error)
                    }
                    queue.finishTransaction(transaction)

                case .deferred:
                    self.requestState = .deferred

                default:
                    break
                }
            }
        }
    }
    // Required by protocol
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {

        // This must be done on the main thread. We’re going to be adjusting the requestState property,
        // and because that’s marked with @Published it may trigger SwiftUI views to be updated.
        DispatchQueue.main.async {

            // Store the returned products
            self.loadedProducts = response.products

            guard let unlock = self.loadedProducts.first else {
                self.requestState = .failed(StoreError.missingProduct)
                return
            }
            if response.invalidProductIdentifiers.isEmpty == false {
                print("Alert! Received invalid product identifiers \(response.invalidProductIdentifiers)")
                self.requestState = .failed(StoreError.invalidIdentifiers)
                return
            }
            self.requestState = .loaded(unlock)
        }
    }

    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

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
        case loaded
        case failed
        case purchased
        case deferred
    }

    @Published var requestState = RequestState.loading

    private let dataController: DataController
    private let request: SKProductsRequest
    private let loadedProducts = [SKProduct]()

    init(dataController: DataController) {
        self.dataController = dataController

        let productIDs = Set(["com.Alex.Po.YourPiano.unlock"])
        request = SKProductsRequest(productIdentifiers: productIDs)

        // Because we inherit from NSObject
        super.init()
        // Start watching the payment queue
        SKPaymentQueue.default().add(self)
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

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // more to come
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // more to come
    }
}

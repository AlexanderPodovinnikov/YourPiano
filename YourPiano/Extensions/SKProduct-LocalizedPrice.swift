//
//  SKProduct-LocalizedPrice.swift
//  YourPiano
//
//  Created by Alex Po on 25.07.2022.
//

import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}

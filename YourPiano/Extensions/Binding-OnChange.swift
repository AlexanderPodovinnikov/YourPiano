//
//  Binding-OnChange.swift
//  YourPiano
//
//  Created by Alex Po on 30.06.2022.
//

import SwiftUI

extension Binding {

    // we call this an escaping function, because its usage escapes onChange() itself
    // and will instead happen at some unknown point in the future.

    /// Handles changes to the Binding wrapped property value.
    /// - Parameter handler: Method to execute when the property value changed.
    /// - Returns: Binding wrapper for the property.
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}

// use it like $someMonitoringValue.onChange(update)
//
// func update() {
// logic to save changes
//
// }

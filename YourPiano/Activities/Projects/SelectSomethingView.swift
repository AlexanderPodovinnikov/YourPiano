//
//  SelectSomethingView.swift
//  YourPiano
//
//  Created by Alex Po on 04.07.2022.
//

import SwiftUI

struct SelectSomethingView: View {
    var body: some View {
        Text("Please, select something from the menu to begin.")
            .italic()
            .foregroundColor(.secondary)
    }
}

struct SelectSomethingView_Previews: PreviewProvider {
    static var previews: some View {
        SelectSomethingView()
    }
}

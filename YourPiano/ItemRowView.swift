//
//  ItemRowView.swift
//  YourPiano
//
//  Created by Alex Po on 30.06.2022.
//

import SwiftUI

// Вся эта канитель нужна для того, чтобы было куда засунуть @ObservedObject чтобы вид мог обновиться, когда сработает objectWillChange
struct ItemRowView: View {
    @ObservedObject var item: Item
    
    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Text(item.itemTitle)
        }
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(item: Item.example)
    }
}

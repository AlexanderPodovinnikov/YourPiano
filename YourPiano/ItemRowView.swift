//
//  ItemRowView.swift
//  YourPiano
//
//  Created by Alex Po on 30.06.2022.
//

import SwiftUI

// Вся эта канитель нужна для того, чтобы было куда засунуть @ObservedObject чтобы вид мог обновиться, когда сработает objectWillChange
struct ItemRowView: View {
    @ObservedObject var project: Project
    @ObservedObject var item: Item
    
    var icon: some View {
        if item.completed {
            return Image(systemName: "checkmark.circle")
                        .foregroundColor(Color(project.projectColor))
        } else if item.priority == 3 {
            return Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(Color(project.projectColor))
        }else {
            return Image(systemName: "checkmark.circle")
                .foregroundColor(.clear)
        }
        
    }
    
    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(item.itemTitle)
            } icon: {
                icon
            }
            
        }
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(project: Project.example, item: Item.example)
    }
}

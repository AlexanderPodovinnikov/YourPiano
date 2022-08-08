//
//  ItemsListView.swift
//  YourPiano
//
//  Created by Alex Po on 07.07.2022.
//

import SwiftUI

/// A simple list of items, that work as navigation link, with a title.
struct ItemsListView: View {

    /// A title of the list.
    let title: LocalizedStringKey
    @Binding var items: ArraySlice<Item>

    #if os(macOS)
    let circleSize = 16.0
    let circleStrokeWidth = 2.0
    let horizontalSpacing = 10.0
    #else
    let circleSize = 44.0
    let circleStrokeWidth = 3.0
    let horizontalSpacing = 20.0
    #endif

    var body: some View {
        Group {
            if items.isEmpty {
                EmptyView()
            } else {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top)

                ForEach(items) {item in
                    NavigationLink(destination: EditItemView(item: item)) {
                        HStack(spacing: horizontalSpacing) {
                            Circle()
                            // .strokeBorder instead of .stroke prevents circles spread
                            // outside their buttons in macOS, because it strokes INSIDE
                                .strokeBorder(
                                    Color(item.project?.projectColor ?? "Light Blue"),
                                    lineWidth: circleStrokeWidth
                                )
                                .frame(width: circleSize, height: circleSize)
                            VStack(alignment: .leading) {
                                Text(item.itemTitle)
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if !item.itemDetail.isEmpty {
                                    Text(item.itemDetail)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        #if os(iOS)
                        .padding()
                        .background(Color.secondarySystemGroupedBackground)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 5)
                        .frame(maxWidth: .infinity, alignment: .leading) // ???
                        #endif
                    }
                }
            }
        }
    }
}

// struct ItemsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemsListView()
//    }
// }

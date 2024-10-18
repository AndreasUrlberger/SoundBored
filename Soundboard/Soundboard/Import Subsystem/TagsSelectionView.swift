//
//  TagsSelectionView.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 11.10.24.
//

import SwiftUI

struct TagsSelectionView: View {
    @State var availableTags: [Tag]
    @Binding var selectedTags: [Tag]

    var body: some View {
        List(availableTags, id: \.name) { tag in
            TagRow(tag: tag, isSelected: selectedTags.contains(tag)) {
                toggleTag(tag)
            }
        }
    }

    private func toggleTag(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll(where: { $0 == tag })
        } else {
            selectedTags.append(tag)
        }
    }
}

struct TagRow: View {
    var tag: Tag
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack {
                Text(tag.name)
                    .font(.subheadline)
                    .padding(4)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .contentShape(Rectangle())
        })
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TagsSelectionView(availableTags: Library.sampleTags, selectedTags: .constant([]))
}

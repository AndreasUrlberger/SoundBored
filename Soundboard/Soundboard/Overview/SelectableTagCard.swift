//
//  SelectableTagCard.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 14.10.24.
//

import SwiftUI

struct SelectableTagCard: View {
    @Bindable var filterTagModel: FilterTagSelectionViewModel
    @State var tag: Tag
    
    private var selected: Bool {
        filterTagModel.selectedTags.contains(tag)
    }
    
    var body: some View {
        Button(action: {
            if selected {
                filterTagModel.deselectTag(tag)
            } else {
                filterTagModel.selectTag(tag)
            }
        }) {
            Label {
                Text(tag.name)
            } icon: {
                Image(systemName: selected ? "checkmark.circle.fill" : "checkmark.circle")
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(tag.theme.mainColor)
        .foregroundStyle(tag.theme.accentColor)
        .cornerRadius(100)
    }
}

#Preview {
    SelectableTagCard(filterTagModel: .init(soundsModel: SoundsViewModel.MockSoundsModel), tag: Library.sampleTags[0])
}

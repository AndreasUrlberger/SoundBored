//
//  TagFilterSelection.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 14.10.24.
//

import SwiftUI

struct FilterTagSelection: View {
    @State private var filterTagsModel: FilterTagSelectionViewModel
    
    init(soundsModel: SoundsViewModel) {
        filterTagsModel = FilterTagSelectionViewModel(soundsModel: soundsModel)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(filterTagsModel.tags, id: \.name) { tag in
                    SelectableTagCard(filterTagModel: filterTagsModel, tag: tag)
                }
            }
            .padding(.horizontal)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    FilterTagSelection(soundsModel: SoundsViewModel.MockSoundsModel)
}

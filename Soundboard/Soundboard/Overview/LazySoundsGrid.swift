//
//  LazySoundsGrid.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 12.10.24.
//

import SwiftUI

struct LazySoundsGrid: View {
    @Environment(SoundsViewModel.self) private var soundsModel
    let columns = [
        GridItem(.adaptive(minimum: 75)) // You can adjust the minimum width here
    ]
    var filteredSounds: [Sound] {
        soundsModel.sounds.filter { sound in
            // At least one of the tags must be in filterTags.
            !Set(sound.tags).isDisjoint(with: soundsModel.filterTags)
        }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(filteredSounds, id: \.id) { sound in
                SoundSquareView(sound: sound)
            }
        }
        .padding()
    }
}

#Preview {
    LazySoundsGrid()
}

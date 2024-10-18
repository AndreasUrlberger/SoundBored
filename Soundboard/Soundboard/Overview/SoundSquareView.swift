//
//  SoundSquareView.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 12.10.24.
//

import SwiftUI

struct SoundSquareView: View {
    @Environment(SoundsViewModel.self) private var soundsModel
    @Environment(\.colorScheme) var colorScheme
    @State var sound: Sound

    private var selected: Bool {
        soundsModel.currentlyPlayingSound?.id == sound.id
    }

    private var theme: Theme {
        // Take the first tag that is also part of the filter tags. Otherwise we might show this sound in a tag color that is actually filtered out.
        sound.tags.first(where: { soundsModel.filterTags.contains($0) })?.theme ?? Theme.tan
    }
    
    var body: some View {
        Button(action: {
            soundsModel.toggleSound(sound)
        }) {
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.mainColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke((colorScheme == .dark ? .white : .black), lineWidth: 3)
                )
                .aspectRatio(1, contentMode: .fill)
                .overlay {
                    Text(sound.name)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(theme.accentColor)
                        .font(.custom("Oswald", size: 16))
                        .padding(4)
                }
        }
        .buttonStyle(PlainButtonStyle()) // Use plain style to avoid default button appearance
    }
}

#Preview {
    SoundSquareView(sound: Library.sampleAppSounds[0])
        .frame(maxWidth: 80, maxHeight: 120)
        .environment(SoundsViewModel.MockSoundsModel)
}

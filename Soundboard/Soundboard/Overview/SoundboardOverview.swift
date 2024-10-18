//
//  SoundboardOverview.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 08.10.24.
//

import SwiftUI
import os
import ConfettiView

// Show a list of sounds categories, uncategorised, and maybe things like random sound etc.
struct SoundboardOverview: View {
    @Environment(SoundsViewModel.self) private var soundsModel
    @State private var localImporterOpen: Bool = false
    @State private var onlineSoundSheetOpen: Bool = false
    @State private var confettiEnabled: Bool = true
    // Need to trigger a re-render of the confettiView each time the confettiIcons changes, because ConfettiView is not doing that by itself.
    @State private var confettiIcons: [Confetti] = []
    @State private var confettiViewID = UUID()

    var body: some View {
        ZStack {
            NavigationStack {
                LocalImportView(importerOpen: $localImporterOpen)
                FilterTagSelection(soundsModel: soundsModel)
                ScrollView { LazySoundsGrid() }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { confettiEnabled.toggle() }) {
                            Image(systemName: confettiEnabled ? "party.popper.fill" : "party.popper")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(action: { localImporterOpen = true }) {
                                Label("Import Local File", systemImage: "folder")
                            }
                            Button(action: { onlineSoundSheetOpen = true }) {
                                Label("Search Online", systemImage: "icloud.and.arrow.down")
                            }
                        }
                        label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .navigationTitle("Sounds")
                .sheet(isPresented: $onlineSoundSheetOpen) {
                    FreesoundDownloadView()
                }
            }
            if soundsModel.currentlyPlayingSound != nil && confettiEnabled {
                ConfettiView(confetti: confettiIcons)
                    .id(confettiViewID)  // Force ConfettiView to rebuild with new id
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: soundsModel.currentlyPlayingSound) {
            guard let sound = soundsModel.currentlyPlayingSound else {
                confettiIcons = []
                confettiViewID = UUID()  // Trigger re-render
                return
            }
            // Always return a new array instance
            confettiIcons = sound.tags.flatMap(\.icons).map { Confetti.text($0) }
            confettiViewID = UUID() // Trigger re-render
        }
    }
}

#Preview {
    SoundboardOverview()
        .environment(SoundsViewModel.MockSoundsModel)
}

//
//  SoundboardApp.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 07.10.24.
//

import SwiftUI

@main
struct SoundboardApp: App {
    @State var soundsViewModel = SoundsViewModel()

    var body: some Scene {
        WindowGroup {
            SoundboardOverview()
        }
        .environment(soundsViewModel)
    }
}

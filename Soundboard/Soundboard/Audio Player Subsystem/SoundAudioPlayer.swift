//
//  SoundAudioPlayer.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 08.10.24.
//

import Foundation
import AVFoundation
import os

@Observable class SoundAudioPlayer: NSObject, AVAudioPlayerDelegate {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Soundboard",
        category: String(describing: SoundAudioPlayer.self)
    )

    var currentSound: Sound?
    private var audioPlayer: AVAudioPlayer?
    private var playerStoppedCallback: (() -> Void)?

    func play(sound: Sound, playerStoppedCallback: (() -> Void)? = nil) {
        stop()
        self.playerStoppedCallback = playerStoppedCallback
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: sound.fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            currentSound = sound
        } catch {
            logger.error("Failed to play sound: \(error)")
        }
    }

    func stop() {
        audioPlayer?.stop()
        currentSound = nil
    }

    func pause() {
        audioPlayer?.pause()
    }

    func resume() {
        audioPlayer?.play()
    }

    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playerStoppedCallback?()
        currentSound = nil
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: (any Error)?) {
        playerStoppedCallback?()
        currentSound = nil
    }
}

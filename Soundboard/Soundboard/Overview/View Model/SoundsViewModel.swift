//
//  SoundViewModel.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 08.10.24.
//

import Foundation
import os

@Observable class SoundsViewModel {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Soundboard",
        category: String(describing: SoundsViewModel.self)
    )

    var tags: [Tag]
    var sounds: [Sound]
    var fileImporterOpen: Bool
    var filterTags: Set<Tag>
    private var audioPlayerService: SoundAudioPlayer

    var currentlyPlayingSound: Sound? {
        audioPlayerService.currentSound
    }
    
    init() {
        let tags = Library.loadTags()
        self.tags = tags
        self.sounds = Library.loadAppSounds(tags: tags)
        self.fileImporterOpen = false
        self.audioPlayerService = SoundAudioPlayer()
        self.filterTags = Set(tags)
    }

    func playSound(_ sound: Sound) {
        audioPlayerService.play(sound: sound)
    }

    func stopSound() {
        audioPlayerService.stop()
    }

    func toggleSound(_ sound: Sound) {
        if audioPlayerService.isPlaying() && audioPlayerService.currentSound == sound {
            stopSound()
        } else {
            playSound(sound)
        }
    }

    func importFile(file: URL, targetName: String, tags: [Tag] = []) throws {
        logger.debug("Importing a local file. (file url: \(file.absoluteString), target name: \(targetName), tags: \(tags.map(\.name)))")
        let soundFileUrl = try Library.saveFileToDocuments(from: file)

        let sound = Sound(name: targetName, fileURL: soundFileUrl, tags: tags)
        sounds.append(sound)
    }
    
    func importOnlineFile(searchName: String, filename: String, tags: [Tag]) async throws {
        logger.debug("Importing an online file. (search name: \(searchName), filename: \(filename), tags: \(tags.map(\.name)))")
        let fileUrl = try await FreesoundLibrary.downloadFileWithName(name: searchName, targetName: filename)

        do {
            try importFile(file: fileUrl, targetName: filename, tags: tags)
        } catch let error as Library.ImportError {
            throw switch error {
            case .InvalidFile: FreesoundLibrary.FreesoundError.ProcessingError
            case .ProcessingError: FreesoundLibrary.FreesoundError.ProcessingError
            case .SavingFailed: FreesoundLibrary.FreesoundError.SavingFailed
            }
        }
    }
}

extension SoundsViewModel {
    static let MockSoundsModel = SoundsViewModel()
}

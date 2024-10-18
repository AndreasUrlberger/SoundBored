//
//  AppSoundLoader.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 07.10.24.
//

import Foundation
import os

public class Library {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Soundboard",
        category: String(describing: Library.self)
    )
    
    public enum ImportError: Error {
        case InvalidFile
        case ProcessingError
        case SavingFailed
    }
    
    class SoundFileJson: Codable {
        let name: String
        let filename: String
        let tags: [String]

        init (name: String, filename: String, tags: [String]) {
            self.name = name
            self.filename = filename
            self.tags = tags
        }
    }
    
    class TagJson: Codable {
        let name: String
        let icons: [String]
        
        init (name: String, icons: [String]) {
            self.name = name
            self.icons = icons
        }
    }

    static func decodeTagsFileJson() -> [TagJson] {
        logger.debug("Load tags file.")
        if let url = Bundle.main.url(forResource: "tags", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([TagJson].self, from: data)
                return jsonData
            } catch {
                logger.error("Failed decoding tags file. (url: \(url))")
            }
        }
        return []
    }
    
    static func loadTags() -> [Tag] {
        let jsonTags = decodeTagsFileJson()
        let tags: [Tag] = jsonTags.map { jsonTag in
            Tag(name: jsonTag.name, icons: jsonTag.icons)
        }
        // Simply use the index of the tag to choose a theme.
        for (index, tag) in tags.enumerated() {
            tag.theme = Theme.allCases[index % Theme.allCases.count]
        }
        return tags
    }

    static func decodeSoundsFileJson() -> [SoundFileJson] {
        logger.debug("Load sounds file.")
        if let url = Bundle.main.url(forResource: "sounds", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([SoundFileJson].self, from: data)
                return jsonData
            } catch {
                logger.error("Failed decoding sounds file. (url: \(url))")
            }
        }
        return []
    }

    static func loadAppSounds(tags: [Tag]) -> [Sound] {
        logger.debug("Started loading of app sounds.")
        let soundsFile: [SoundFileJson] = decodeSoundsFileJson()
        // Just use the Set to get unique values.
        let sounds: [Sound] = soundsFile.compactMap { soundFile in
            guard let fileURL = Bundle.main.url(forAuxiliaryExecutable: soundFile.filename) else {
                logger.warning("Could not find file \(soundFile.filename) in app bundle.")
                return nil
            }
            // We intentionally do not filter the given tags because this would not preserve the order of the soundFile tags.
            let soundTags = soundFile.tags.compactMap { tagName in
                tags.first(where: { $0.name == tagName })
            }
            let sound = Sound(name: soundFile.name, fileURL: fileURL, tags: soundTags)
            return sound
        }

        return sounds
    }

    // Tries to copy file from provided url to app's documents folder and returns its url if successfull.
    static func saveFileToDocuments(from url: URL) throws -> URL {
        // Check that the provided file url actually exists.
        let givenUrlReachable = (try? url.checkPromisedItemIsReachable()) ?? false
        guard url.isFileURL && givenUrlReachable else {
            logger.warning("Provided file url is not a file or is not reachable. (url: \(url))")
            throw ImportError.InvalidFile
        }

        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            logger.warning("Failed to get documents url.")
            throw ImportError.ProcessingError
        }

        // Choose UUID as a filename to avoid any naming collisions.
        let filename = UUID().uuidString
        let targetUrl = documentsUrl.appendingPathComponent(filename).appendingPathExtension(url.pathExtension)

        // Copy file
        do {
            try FileManager.default.copyItem(at: url, to: targetUrl)
        } catch {
            logger.debug("Failed to copy file from \(url) to \(targetUrl).")
            throw ImportError.SavingFailed
        }

        return targetUrl
    }

    static var sampleTags: [Tag] = loadTags()
    static let sampleAppSounds: [Sound] = loadAppSounds(tags: sampleTags)

    private init() {}
}

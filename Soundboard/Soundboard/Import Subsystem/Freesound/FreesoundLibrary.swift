//
//  FreesoundLibrary.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 10.10.24.
//

import Foundation
import os

class FreesoundLibrary {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Soundboard",
        category: String(describing: FreesoundLibrary.self)
    )
    
    public enum FreesoundError: Error {
        case InvalidInput
        case NoSoundFound
        case NoPreviewFound
        case DownloadFailed
        case SavingFailed
        case ProcessingError
    }
    
    // Searches for the given name in freesound.org, downloads the first matching file, and returns the local url. Returns nothing if it fails to download the sound.
    static func downloadFileWithName(name: String, targetName: String) async throws -> URL {
        logger.debug("User requested download of \(name) from freesound.org")
        let id = try await searchSoundByName(searchTerm: name)
        
        logger.debug("Found a matching sound with id \(id).")
        let previewUrl = try await getPreviewUrl(id: id)

        logger.debug("Found a preview url for \(id). Url: \(previewUrl).")
        let fileUrl = try await downloadFreesoundFile(previewPath: previewUrl)

        logger.debug("Successfully downloaded file to device into \(fileUrl).")
        return fileUrl
    }

    private static func searchSoundByName(searchTerm: String) async throws -> String {
        logger.debug("Searching freesound.org for \(searchTerm).")
        guard let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw FreesoundError.InvalidInput
        }
        let token = await Constants.getFreesoundApiToken()
        guard let url = URL(string: "https://freesound.org/apiv2/search/text/?query=\(encodedSearchTerm)&token=\(token)") else {
            throw FreesoundError.ProcessingError
        }
        let tuple: (Data, URLResponse)? = try? await URLSession.shared.data(from: url)
        let data = tuple?.0
        guard let data else {
            throw FreesoundError.DownloadFailed
        }
        
        guard let response: SearchResponse = try? JSONDecoder().decode(SearchResponse.self, from: data) else {
            throw FreesoundError.ProcessingError
        }
        logger.debug("Result of name search: \(response.results)")
        
        guard let first = response.results.first else {
            throw FreesoundError.NoSoundFound
        }
        return String(first.id)
    }
    
    private static func getPreviewUrl(id: String) async throws -> String {
        logger.debug("Getting preview url for \(id).")
        let token = await Constants.getFreesoundApiToken()
        guard let url = URL(string: "https://freesound.org/apiv2/sounds/\(id)/?token=\(token)&fields=previews") else {
            throw FreesoundError.ProcessingError
        }
        let tuple: (Data, URLResponse)? = try? await URLSession.shared.data(from: url)
        let data = tuple?.0
        guard let data else {
            throw FreesoundError.DownloadFailed
        }
        guard let response: PreviewResponse = try? JSONDecoder().decode(PreviewResponse.self, from: data) else {
            throw FreesoundError.ProcessingError
        }

        guard let previewUrl = response.previews.previewHqMp3 else {
            throw FreesoundError.NoPreviewFound
        }

        return previewUrl
    }
    
    // Tries to download the given preview from freesound.org. Returns the url of the save file or nil if the download failed.
    private static func downloadFreesoundFile(previewPath: String) async throws -> URL {
        logger.debug("Downloading preview file from \(previewPath).")
        guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw FreesoundError.ProcessingError
        }
        // Use UUID as filename to avoid naming collisions.
        let destinationUrl = cacheDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp3")
        guard let previewUrl = URL(string: previewPath) else {
            throw FreesoundError.ProcessingError
        }
        
        let downloadResponse: (Data, URLResponse)? = try? await URLSession.shared.data(from: previewUrl)
        let data = downloadResponse?.0
        guard let data else {
            // Download failed.
            logger.debug("Failed to download preview file from \(previewPath).")
            throw FreesoundError.DownloadFailed
        }
        
        do {
            try data.write(to: destinationUrl)
            return destinationUrl
        } catch {
            throw FreesoundError.SavingFailed
        }
    }
    
    class SearchResult: Codable {
        var id: Int
        
        init(id: Int) {
            self.id = id
        }
    }
    
    class SearchResponse: Codable {
        var results: [SearchResult]
        
        init(results: [SearchResult] = []) {
            self.results = results
        }
    }
    
    class Preview: Codable {
        var previewHqMp3: String?
        var previewLqMp3: String?
        var previewHqOgg: String?
        var previewLqOgg: String?
        
        enum CodingKeys: String, CodingKey {
            case previewHqMp3 = "preview-hq-mp3"
            case previewLqMp3 = "preview-lq-mp3"
            case previewHqOgg = "preview-hq-ogg"
            case previewLqOgg = "preview-lq-ogg"
        }
    }
    
    class PreviewResponse: Codable {
        var previews: Preview
    }
}


enum Constants {
    static func loadAPIKeys() async throws {
        let request = NSBundleResourceRequest(tags: ["APIKeys"])
        try await request.beginAccessingResources()
        guard let url = Bundle.main.url(forResource: "APIKeys", withExtension: "json") else {
            return
        }
        let data = try Data(contentsOf: url)
        APIKeys.storage = try JSONDecoder().decode([String: String].self, from: data)
        
        request.endAccessingResources()
    }
    
    static func getFreesoundApiToken() async -> String {
        if APIKeys.freesoundApiToken.isEmpty {
            do {
                try await loadAPIKeys()
            } catch {
                // Don't really care about that.
            }
        }
        return APIKeys.freesoundApiToken
    }
    
    enum APIKeys {
        fileprivate(set) static var storage = [String: String]()
        
        static var freesoundApiToken: String { storage["freesound"] ?? "" }
    }
}

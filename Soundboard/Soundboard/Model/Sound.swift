//
//  Sound.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 07.10.24.
//

import Foundation

class Sound: Identifiable, Equatable {
    static func == (lhs: Sound, rhs: Sound) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: UUID
    var name: String
    var fileURL: URL
    var tags: [Tag]

    init(id: UUID = UUID(), name: String, fileURL: URL, tags: [Tag] = []) {
        self.id = id
        self.name = name
        self.fileURL = fileURL
        self.tags = tags
    }

    func addTag(_ tag: Tag) {
        tags.append(tag)
    }

    func removeTag(_ tag: Tag) {
        tags.removeAll(where: { $0 == tag })
    }
}

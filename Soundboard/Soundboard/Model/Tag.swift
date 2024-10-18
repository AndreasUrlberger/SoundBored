//
//  Tag.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 07.10.24.
//

import Foundation
import SwiftUI

class Tag: Hashable {
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    var name: String
    var icons: [String]
    // Use Theme instead of color
    var theme: Theme

    init(name: String, icons: [String] = [], theme: Theme = .bubblegum) {
        self.name = name
        self.icons = icons
        self.theme = theme
    }
}

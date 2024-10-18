//
//  Theme.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 12.10.24.
//

import SwiftUI

enum Theme: String, CaseIterable, Identifiable, Codable {
    case bubblegum
    case buttercup
    case lavender
    case navy
    case oxblood
    case periwinkle
    case poppy
    case seafoam
    case sky
    case tan

    var accentColor: Color {
        switch self {
        case .bubblegum, .buttercup, .lavender, .periwinkle, .poppy, .seafoam, .sky, .tan:
            return .black
        case .navy, .oxblood: return .white
        }
    }
    var mainColor: Color {
        Color(rawValue)
    }
    var name: String {
        rawValue.capitalized
    }
    var id: String {
        name
    }
}

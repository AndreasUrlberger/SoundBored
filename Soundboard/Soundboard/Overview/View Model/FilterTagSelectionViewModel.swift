//
//  FilterTagSelectionViewModel.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 14.10.24.
//

import Foundation

@Observable class FilterTagSelectionViewModel {
    var selectedTags: Set<Tag> {
        soundsModel?.filterTags ?? []
    }
    var tags: [Tag] {
        soundsModel?.tags ?? []
    }
    private weak var soundsModel: SoundsViewModel?
    
    init(soundsModel: SoundsViewModel) {
        self.soundsModel = soundsModel
    }
    
    func selectTag(_ tag: Tag) {
        soundsModel?.filterTags.insert(tag)
    }
    
    func deselectTag(_ tag: Tag) {
        soundsModel?.filterTags.remove(tag)
    }
}

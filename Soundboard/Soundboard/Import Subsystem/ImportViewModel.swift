//
//  FreesoundImportViewModel.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 12.10.24.
//

import Foundation

@Observable class ImportViewModel {
    var targetFileName: String = ""
    var soundTags: [Tag] = []
    var errorMessage: String = ""
    var showAlert: Bool = false
}

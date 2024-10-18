//
//  ImportDetailsView.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 11.10.24.
//

import SwiftUI

struct LocalImportDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SoundsViewModel.self) private var soundsModel
    @Binding var soundName: String
    @Binding var soundTags: [Tag]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name of Sound", text: $soundName)
                Section("Tags") {
                    TagsSelectionView(availableTags: soundsModel.tags, selectedTags: $soundTags)
                }
            }
            .navigationTitle("Import Sound")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Import") {
                        dismiss()
                    }
                    .disabled(soundName.isEmpty)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        soundName = ""
                        soundTags = []
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LocalImportDetailsView(soundName: .constant(""), soundTags: .constant([]))
            .environment(SoundsViewModel.MockSoundsModel)
    }
}

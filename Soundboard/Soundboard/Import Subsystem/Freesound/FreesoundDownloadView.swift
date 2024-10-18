//
//  FreesoundDownloadView.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 10.10.24.
//

import SwiftUI
import os

struct FreesoundDownloadView: View {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Soundboard",
        category: String(describing: FreesoundDownloadView.self)
    )

    @Environment(\.dismiss) private var dismiss
    @Environment(SoundsViewModel.self) private var soundsModel
    @State private var importViewModel = ImportViewModel()
    @State private var searchText = ""
    @State private var searching = false

    var body: some View {
        NavigationStack {
            LoadingView(isShowing: $searching) {
                Form {
                    TextField("Name of Sound", text: $searchText)
                    TextField("Name of imported Sound", text: $importViewModel.targetFileName)
                    
                    Section("Tags") {
                        TagsSelectionView(
                            availableTags: soundsModel.tags,
                            selectedTags: $importViewModel.soundTags
                        )
                    }
                }
                .navigationTitle("Search Sound")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Download") {
                            download()
                        }
                        .disabled(
                            searchText.isEmpty ||
                            importViewModel.targetFileName.isEmpty ||
                            searching
                        )
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .alert(importViewModel.errorMessage, isPresented: $importViewModel.showAlert) {
                    Button("OK", role: .cancel) {}
                }
            }
        }
    }
    
    func download() {
        searching = true
        Task {
            do {
                try await soundsModel.importOnlineFile(
                    searchName: searchText,
                    filename: importViewModel.targetFileName,
                    tags: importViewModel.soundTags
                )
                searching = false
                dismiss()
            } catch let error as FreesoundLibrary.FreesoundError {
                logger.warning("Error downloading sound: \(error)")
                importViewModel.errorMessage = switch error {
                case .NoSoundFound: "Was not able to find sound"
                case .DownloadFailed: "Was not able to download sound"
                case .InvalidInput: "Invalid input"
                case .NoPreviewFound: "Could not find preview for sound"
                case .ProcessingError: "Processing Error"
                case .SavingFailed: "Failed to save sound"
                }
                importViewModel.showAlert = true
            } catch {
                logger.warning("Unknown error: \(error)")
                importViewModel.errorMessage = "Unknown error: \(error)"
                importViewModel.showAlert = true
            }
            
            searching = false
        }
    }
}

#Preview {
    FreesoundDownloadView()
        .environment(SoundsViewModel.MockSoundsModel)
}

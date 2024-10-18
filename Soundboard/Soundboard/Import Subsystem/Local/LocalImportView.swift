//
//  LocalImportView.swift
//  Soundboard
//
//  Created by Andreas Urlberger on 10.10.24.
//

import SwiftUI
import os

struct LocalImportView: View {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Soundboard",
        category: String(describing: LocalImportView.self)
    )

    @Environment(SoundsViewModel.self) private var soundsModel
    @Binding var importerOpen: Bool
    @State private var importViewModel = ImportViewModel()
    @State private var localImportTagSelectionOpen: Bool = false
    @State private var selectedFileUrl: URL?

    var body: some View {
        // We don't want this view to be visible in the parent view, we just want to show the file importer. However, I don't want the file importer code in the parent class.
        Rectangle()
            .frame(width: 0, height: 0)
            .fileImporter(
            isPresented: $importerOpen,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false,
            onCompletion: { result in
                switch result {
                case .success(let url):
                    // Copy file to this app's documents folder
                    guard let fileUrl = url.first else {
                        logger.debug("User did not provide a file.")
                        return
                    }
                    logger.debug("User provided a local file for import: \(fileUrl)")
                    selectedFileUrl = fileUrl
                    localImportTagSelectionOpen = true
                case .failure:
                    logger.debug("User failed to provide a proper file.")
                }
            })
        .sheet(
            isPresented: $localImportTagSelectionOpen,
            onDismiss:   {
                guard let selectedFileUrl else {
                    return
                }
                if !importViewModel.targetFileName.isEmpty {
                    do {
                        try soundsModel.importFile(
                            file: selectedFileUrl,
                            targetName: importViewModel.targetFileName,
                            tags: importViewModel.soundTags
                        )
                    } catch let error as Library.ImportError {
                        importViewModel.errorMessage = switch error {
                        case .InvalidFile: "Could not read file"
                        case .ProcessingError: "Processing Error"
                        case .SavingFailed: "Failed to save sound"
                        }
                        importViewModel.showAlert = true
                    } catch {
                        importViewModel.errorMessage = "Unknown error: \(error)"
                        importViewModel.showAlert = true
                    }
                }
            }, content: {
                LocalImportDetailsView(
                    soundName: $importViewModel.targetFileName,
                    soundTags: $importViewModel.soundTags
                )
                .onAppear {
                    // We don't want any of the fields prefilled.
                    importViewModel.targetFileName = ""
                    importViewModel.soundTags.removeAll()
                }
            })
        .alert(importViewModel.errorMessage, isPresented: $importViewModel.showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

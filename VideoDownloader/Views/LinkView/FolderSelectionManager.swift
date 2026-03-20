//
//  FolderSelectionManager.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 19/03/26.
//

import SwiftUI
import Combine

class FolderSelectionManager: ObservableObject {
    @Published var showFolderSelection = false
    @Published var pendingVideo: (videoURL: URL, thumbnailURL: URL?, sourceURL: String)?
    var folderManager = FolderManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Reference to LinkViewModel to update its state
    weak var linkViewModel: LinkViewModel?
    
    func handleDownloadedVideo(videoURL: URL, thumbnailURL: URL?, sourceURL: String) {
        pendingVideo = (videoURL, thumbnailURL, sourceURL)
        showFolderSelection = true
    }
    
    func saveToSelectedFolder(folderId: UUID) {
        guard let video = pendingVideo else { return }
        
        let savedVideo = SavedVideo(
            videoURL: video.videoURL,
            thumbnailURL: video.thumbnailURL,
            musicTrack: nil,
            musicStartTime: 0,
            musicEndTime: 0
        )
        
        // Save video
        SavedVideosManager.shared.saveVideo(savedVideo)
        
        // Add to folder
        folderManager.addVideoToFolder(videoId: savedVideo.id, folderId: folderId)
        
        print("✅ Video saved to folder with ID: \(folderId)")
        
        // Update LinkViewModel state
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.linkViewModel?.isLoading = false
            self.linkViewModel?.isSaving = false
            self.linkViewModel?.postLink = ""
            
            // Fix for localized string - use the language from linkViewModel
            if let language = self.linkViewModel?.language {
                self.linkViewModel?.alertMessage = "Video downloaded and saved to folder!".localized(language)
            } else {
                // Fallback
                self.linkViewModel?.alertMessage = "Video downloaded and saved to folder!"
            }
            
            self.linkViewModel?.didDownloadSuccessfully = true
            self.linkViewModel?.showAlert = true
            
            // Clear pending
            self.pendingVideo = nil
            self.showFolderSelection = false
        }
    }
    
    func cancelFolderSelection() {
        // User cancelled - reset loading state and clear text field
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.linkViewModel?.isLoading = false
            self.linkViewModel?.isSaving = false
            self.linkViewModel?.postLink = ""
            self.linkViewModel?.alertMessage = ""
            
            // Clear pending video
            self.pendingVideo = nil
            self.showFolderSelection = false
        }
    }
    
    func createNewFolder(name: String) {
        folderManager.createFolder(name: name)
        if let newFolder = folderManager.folders.last {
            saveToSelectedFolder(folderId: newFolder.id)
        }
    }
}

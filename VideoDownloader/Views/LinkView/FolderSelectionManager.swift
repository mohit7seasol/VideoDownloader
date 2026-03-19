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
        
        SavedVideosManager.shared.saveVideo(savedVideo)
        folderManager.addVideoToFolder(videoId: savedVideo.id, folderId: folderId)
        
        print("✅ Video saved to folder with ID: \(folderId)")
        
        // Clear pending
        pendingVideo = nil
        showFolderSelection = false
    }
    
    func createNewFolder(name: String) {
        folderManager.createFolder(name: name)
        if let newFolder = folderManager.folders.last {
            saveToSelectedFolder(folderId: newFolder.id)
        }
    }
}

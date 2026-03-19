//
//  HistoryViewModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 16/03/26.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class HistoryViewModel: ObservableObject {
    @Published var savedVideos: [SavedVideo] = []
    @Published var isLoading = false
    @Published var showDeleteAlert = false
    @Published var videoToDelete: SavedVideo?
    @Published var viewMode = 0 // 0 for folders, 1 for videos
    
    func loadVideos() {
        isLoading = true
        savedVideos = SavedVideosManager.shared.getSavedVideos()
        isLoading = false
    }
    
    func confirmDelete(_ video: SavedVideo) {
        videoToDelete = video
        showDeleteAlert = true
    }
    
    func handleDeleteConfirmation(confirmed: Bool) {
        if confirmed, let video = videoToDelete {
            // Remove from folders first
            var folderManager = FolderManager.shared
            for (index, folder) in folderManager.folders.enumerated() {
                folderManager.folders[index].videoIds.removeAll { $0 == video.id }
            }
            folderManager.saveFolders()
            
            // Then delete video
            SavedVideosManager.shared.deleteVideo(video)
            loadVideos()
        }
        videoToDelete = nil
        showDeleteAlert = false
    }
}

// Extension to help with debugging
extension SavedVideo {
    func validateFiles() -> (videoExists: Bool, thumbnailExists: Bool) {
        let fileManager = FileManager.default
        let videoExists = fileManager.fileExists(atPath: videoURL.path)
        let thumbnailExists = thumbnailURL.map { fileManager.fileExists(atPath: $0.path) } ?? false
        return (videoExists, thumbnailExists)
    }
}

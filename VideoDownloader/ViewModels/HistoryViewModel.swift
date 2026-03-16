//
//  HistoryViewModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 16/03/26.
//

import Foundation
import SwiftUI
import Combine

class HistoryViewModel: ObservableObject {
    @Published var savedVideos: [SavedVideo] = []
    @Published var isLoading = false
    @Published var showDeleteAlert = false
    @Published var videoToDelete: SavedVideo?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadVideos()
    }
    
    func loadVideos() {
        isLoading = true
        // Simulate loading delay (remove in production)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.savedVideos = SavedVideosManager.shared.getSavedVideos()
            self?.isLoading = false
        }
    }
    
    func deleteVideo(_ video: SavedVideo) {
        SavedVideosManager.shared.deleteVideo(video)
        loadVideos() // Reload after deletion
    }
    
    func confirmDelete(_ video: SavedVideo) {
        videoToDelete = video
        showDeleteAlert = true
    }
    
    func handleDeleteConfirmation(confirmed: Bool) {
        if confirmed, let video = videoToDelete {
            deleteVideo(video)
        }
        videoToDelete = nil
        showDeleteAlert = false
    }
}

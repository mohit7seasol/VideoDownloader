//
//  SavedVideoView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import SwiftUI
import AVFoundation

struct SavedVideoView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedVideo: SavedVideo?
    @State private var showFullVideoView = false
    
    private let columns: [GridItem] = {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let count = isIPad ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
    }()
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Image("app_bg_image")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                    .onTapGesture {
                        UIApplication.shared.endEditing(true)
                    }
                
                VStack(spacing: 20) {
                    // 1️⃣ Top View (Reuse)
                    TopHomeView()
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .tint(.white)
                        Spacer()
                    } else if viewModel.savedVideos.isEmpty {
                        // Empty state
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "video.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("No Videos Yet")
                                .font(.custom("Urbanist-Bold", size: 20))
                                .foregroundColor(.white)
                            
                            Text("Your downloaded or edited videos will appear here")
                                .font(.custom("Urbanist-Medium", size: 16))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .padding(.horizontal, 40)
                        .offset(y: -40)
                        Spacer()
                    } else {
                        // Video Grid
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.savedVideos) { video in
                                    SavedVideoCardView(video: video) {
                                        viewModel.confirmDelete(video)
                                    }
                                    .onTapGesture {
                                        selectedVideo = video
                                        showFullVideoView = true
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                        }
                    }
                }
                .padding(.top, UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first?.windows
                    .first?.safeAreaInsets.top ?? 0)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showFullVideoView) {
                if let video = selectedVideo {
                    FullVideoView(video: video)
                }
            }
        }
        .alert("Delete Video", isPresented: $viewModel.showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                viewModel.handleDeleteConfirmation(confirmed: false)
            }
            Button("Delete", role: .destructive) {
                viewModel.handleDeleteConfirmation(confirmed: true)
            }
        } message: {
            if let video = viewModel.videoToDelete {
                Text("Are you sure you want to delete \"\(video.musicName ?? "this video")\"?")
            } else {
                Text("Are you sure you want to delete this video?")
            }
        }
        .onAppear {
            viewModel.loadVideos()
        }
    }
}

// MARK: - SavedVideoCardView
struct SavedVideoCardView: View {
    let video: SavedVideo
    let onDelete: () -> Void
    
    @State private var thumbnailImage: UIImage?
    @State private var isLoading = false
    @State private var loadError = false
    @State private var retryCount = 0
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ZStack {
            // Thumbnail Image
            Group {
                if let image = thumbnailImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } else if loadError {
                    // Show error state with retry button
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 30))
                            .foregroundColor(.yellow)
                        Text("Failed to load")
                            .font(.caption)
                            .foregroundColor(.white)
                        Button("Retry") {
                            retryLoadThumbnail()
                        }
                        .font(.caption)
                        .padding(5)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.3))
                } else {
                    // Show loading or placeholder
                    ZStack {
                        Image("no_thumb")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                        
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Delete Button (bottom right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: onDelete) {
                        Image("delete_ic")
                            .resizable()
                            .frame(width: isIPad ? 32 : 22, height: isIPad ? 32 : 22)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(12)
                }
            }
        }
        .frame(height: 180)
        .cornerRadius(12)
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            loadThumbnail()
        }
        .onChange(of: video.id) { _ in
            // Reset and reload when video changes
            thumbnailImage = nil
            loadError = false
            loadThumbnail()
        }
    }
    
    private func retryLoadThumbnail() {
        retryCount += 1
        loadError = false
        thumbnailImage = nil
        loadThumbnail()
    }
    
    private func loadThumbnail() {
        // Prevent multiple loads
        guard !isLoading, thumbnailImage == nil else { return }
        
        // If no thumbnail URL, keep showing no_thumb
        guard let thumbnailURL = video.thumbnailURL else {
            print("No thumbnail URL for video: \(video.id)")
            return
        }
        
        isLoading = true
        print("Loading thumbnail for video: \(video.id) from URL: \(thumbnailURL.path)")
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let fileManager = FileManager.default
            
            // Check if file exists
            guard fileManager.fileExists(atPath: thumbnailURL.path) else {
                DispatchQueue.main.async {
                    print("❌ Thumbnail file not found at path: \(thumbnailURL.path)")
                    self.isLoading = false
                    self.loadError = true
                    
                    // Try to regenerate thumbnail from video if this is a retry
                    if self.retryCount < 2 {
                        self.regenerateThumbnailFromVideo()
                    }
                }
                return
            }
            
            // Load image data
            do {
                let data = try Data(contentsOf: thumbnailURL)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        print("✅ Thumbnail loaded successfully for video: \(video.id)")
                        self.thumbnailImage = image
                        self.isLoading = false
                        self.loadError = false
                    }
                } else {
                    DispatchQueue.main.async {
                        print("❌ Failed to create UIImage from data for video: \(video.id)")
                        self.isLoading = false
                        self.loadError = true
                        
                        // Try to regenerate
                        if self.retryCount < 2 {
                            self.regenerateThumbnailFromVideo()
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("❌ Error loading thumbnail data: \(error.localizedDescription)")
                    self.isLoading = false
                    self.loadError = true
                    
                    // Try to regenerate
                    if self.retryCount < 2 {
                        self.regenerateThumbnailFromVideo()
                    }
                }
            }
        }
    }
    
    private func regenerateThumbnailFromVideo() {
        print("Attempting to regenerate thumbnail from video for: \(video.id)")
        
        DispatchQueue.global(qos: .background).async { [self] in
            let asset = AVAsset(url: video.videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 300, height: 300)
            
            do {
                let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                
                // Save new thumbnail
                guard let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                    DispatchQueue.main.async {
                        self.loadError = true
                        self.isLoading = false
                    }
                    return
                }
                
                let thumbnailPath = appSupportDir.appendingPathComponent("thumb_\(UUID().uuidString).jpg")
                
                if let data = thumbnail.jpegData(compressionQuality: 0.7) {
                    try data.write(to: thumbnailPath)
                    
                    DispatchQueue.main.async {
                        self.thumbnailImage = thumbnail
                        self.isLoading = false
                        self.loadError = false
                        
                        // Update the video's thumbnail URL in storage
                        var updatedVideo = self.video
                        // Note: You'd need to update this in your SavedVideosManager
                        print("✅ Thumbnail regenerated and saved at: \(thumbnailPath.path)")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to regenerate thumbnail: \(error)")
                    self.loadError = true
                    self.isLoading = false
                }
            }
        }
    }
}


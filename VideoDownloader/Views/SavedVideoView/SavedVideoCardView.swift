//
//  SavedVideoCardView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 19/03/26.
//

import SwiftUI
import AVFoundation

struct SavedVideoCardView: View {
    let video: SavedVideo
    let showDeleteButton: Bool // New parameter to control delete button visibility
    let onDelete: () -> Void
    
    @State private var thumbnailImage: UIImage?
    @State private var isLoading = false
    @State private var loadError = false
    @State private var retryCount = 0
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
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
                        Text("Failed to load".localized(self.language))
                            .font(.caption)
                            .foregroundColor(.white)
                        Button("Retry".localized(self.language)) {
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
            
            // Delete Button (bottom right) - Only show if allowed
            if showDeleteButton {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: onDelete) {
                            Image("delete_ic")
                                .resizable()
                                .frame(width: isIPad ? 32 : 18, height: isIPad ? 32 : 20)
                                .foregroundColor(.white)
                                .padding(2)
                                .clipShape(Circle())
                                .padding(.trailing, 0)
                                .padding(.bottom, 68)
                        }
                        .padding(12)
                    }
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

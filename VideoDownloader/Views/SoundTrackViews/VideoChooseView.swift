//
//  VideoChooseView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 13/03/26.
//

import SwiftUI
import PhotosUI
import AVKit
import Lottie

// MARK: - VideoChooseView
struct VideoChooseView: View {
    @Environment(\.dismiss) var dismiss
    @State private var videos: [VideoAsset] = []
    @State private var isLoading = false
    @State private var selectedVideo: VideoAsset?
    @State private var navigateToAddMusic = false
    @State private var showPermissionAlert = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        ZStack {
            // Background Image
            Image("app_bg_image")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Select Video".localized(self.language))
                        .font(.custom("Poppins-Black", size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    // Empty view for balance
                    Color.clear
                        .frame(width: 20, height: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                    Spacer()
                } else if videos.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("No Videos Found".localized(self.language))
                            .font(.custom("Poppins-Black", size: 18))
                            .foregroundColor(.white)
                        
                        Text("Tap below to access your videos".localized(self.language))
                            .font(.custom("Urbanist-Medium", size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    
                    // Access Videos Button
                    Button {
                        checkPermissionAndLoadVideos()
                    } label: {
                        Text("Access Videos".localized(self.language))
                            .font(.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(width: 150)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "1973E8"),
                                        Color(hex: "0E4082")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(25)
                    }
                    .padding(.bottom, 40)
                } else {
                    // Video Grid - Matching uploaded image
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(videos) { video in
                                VideoThumbnailView(video: video)
                                    .onTapGesture {
                                        selectedVideo = video
                                        navigateToAddMusic = true
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            checkPermissionAndLoadVideos()
        }
        .alert("Permission Required".localized(self.language), isPresented: $showPermissionAlert) {
            Button("Cancel".localized(self.language), role: .cancel) { }
            Button("Settings".localized(self.language)) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please grant photo library access to select videos".localized(self.language))
        }
        .navigationDestination(isPresented: $navigateToAddMusic) {
            if let video = selectedVideo {
                AddMusicToVideoView(videoAsset: video)
            }
        }
    }
    
    private func checkPermissionAndLoadVideos() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            loadVideos()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        loadVideos()
                    } else {
                        showPermissionAlert = true
                    }
                }
            }
        default:
            showPermissionAlert = true
        }
    }
    
    private func loadVideos() {
        isLoading = true
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        
        var videoAssets: [VideoAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            videoAssets.append(VideoAsset(asset: asset))
        }
        
        DispatchQueue.main.async {
            self.videos = videoAssets
            self.isLoading = false
        }
    }
}


// MARK: - VideoThumbnailView
struct VideoThumbnailView: View {
    let video: VideoAsset
    @State private var thumbnail: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: (UIScreen.main.bounds.width - 40) / 3, height: (UIScreen.main.bounds.width - 40) / 3)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: (UIScreen.main.bounds.width - 40) / 3, height: (UIScreen.main.bounds.width - 40) / 3)
                    .cornerRadius(12)
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            }
            
            // Duration label - as shown in uploaded image (00:10 format)
            Text(formatDuration(video.duration))
                .font(.custom("Urbanist-Medium", size: 12))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.7))
                .cornerRadius(4)
                .padding(6)
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .fastFormat
        
        PHImageManager.default().requestImage(
            for: video.asset,
            targetSize: CGSize(width: 200, height: 200),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            self.thumbnail = image
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - VideoAsset Model
struct VideoAsset: Identifiable {
    let id = UUID()
    let asset: PHAsset
    
    var duration: TimeInterval {
        asset.duration
    }
}

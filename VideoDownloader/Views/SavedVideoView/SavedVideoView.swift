//
//  SavedVideoView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import SwiftUI

struct SavedVideoView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = HistoryViewModel()
    
    private let columns: [GridItem] = {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let count = isIPad ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
    }()
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ZStack {
            // Background
            Image("app_bg_image")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
                .onTapGesture {
                    // ✅ Dismiss keyboard when tapping background
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
                                    // Navigate to watch video
                                    // You can add navigation here if needed
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
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Thumbnail (full card)
            Group {
                if let thumbnail = thumbnailImage {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Show placeholder while loading or if no thumbnail
                    Color.gray.opacity(0.3)
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Delete button (bottom right)
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
    }
    
    private func loadThumbnail() {
        // Clear current thumbnail
        thumbnailImage = nil
        
        // Load new thumbnail
        guard let thumbnailURL = video.thumbnailURL else {
            print("No thumbnail URL for video: \(video.id)")
            return
        }
        
        // Check if file exists
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: thumbnailURL.path) {
            DispatchQueue.global(qos: .background).async {
                if let data = try? Data(contentsOf: thumbnailURL),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.thumbnailImage = image
                        print("Thumbnail loaded successfully for video: \(video.id)")
                    }
                } else {
                    DispatchQueue.main.async {
                        print("Failed to load thumbnail data for video: \(video.id)")
                    }
                }
            }
        } else {
            print("Thumbnail file does not exist at path: \(thumbnailURL.path)")
        }
    }
}

//
//  SavedAssetsView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 17/04/26.
//

import SwiftUI
import AVKit
import Photos

enum SavedAssetsType: String, CaseIterable {
    case savedPhotos = "Photos"
    case savedVideos = "Videos"
}

struct SavedAssetsView: View {
    @State private var savedImages: [UIImage] = []
    @State private var savedVideos: [URL] = []
    @State private var showDeleteAlert = false
    @State private var itemToDelete: Int?
    @State private var deleteType: SavedAssetsType = .savedPhotos
    @State private var animateGradient = false
    @State private var selectedSegment: SavedAssetsType = .savedPhotos
    @State private var showSaveToGalleryAlert = false
    @State private var videoToSave: URL?
    
    // Dynamic columns based on device with equal spacing
    private var columns: [GridItem] {
        if Device.isIpad {
            // iPad: 5 columns with equal spacing
            return Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)
        } else {
            // iPhone: 3 columns with equal spacing
            return Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
        }
    }
    
    // Dynamic spacing based on device
    private var gridSpacing: CGFloat {
        Device.isIpad ? 12 : 8
    }
    
    // Dynamic image size based on device with equal distribution
    private var imageSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let horizontalPadding: CGFloat = Device.isIpad ? 32 : 20
        let totalSpacing: CGFloat = Device.isIpad ? 12 * 4 : 8 * 2
        let numberOfColumns: CGFloat = Device.isIpad ? 5 : 3
        
        return (screenWidth - horizontalPadding - totalSpacing) / numberOfColumns
    }
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        if Device.isIpad {
            GeometryReader { geometry in
                ZStack {
                    Image("app_bg_image")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // TopHomeView for iPad
                        TopHomeView()
                            .padding(.top, UIApplication.shared.connectedScenes
                                .compactMap { $0 as? UIWindowScene }
                                .first?.windows
                                .first?.safeAreaInsets.top ?? 0)
                        
                        // Segment Control
                        segmentControlView
                            .padding(.horizontal, 24)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        
                        if selectedSegment == .savedPhotos {
                            if savedImages.isEmpty {
                                // Existing Empty State View for Photos
                                ScrollView {
                                    VStack(spacing: 25) {
                                        Spacer(minLength: 0)
                                        
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(hex: "#FC466B").opacity(0.3),
                                                            Color(hex: "#3F5EFB").opacity(0.3)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 160, height: 160)
                                                .scaleEffect(animateGradient ? 1.1 : 1.0)
                                                .animation(
                                                    Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                                    value: animateGradient
                                                )
                                            
                                            Circle()
                                                .fill(Color.white.opacity(0.1))
                                                .frame(width: 140, height: 140)
                                            
                                            Image(systemName: "photo.stack")
                                                .font(.system(size: 60))
                                                .foregroundColor(.white)
                                                .shadow(color: .white.opacity(0.3), radius: 10)
                                        }
                                        
                                        Text("No Saved Images".localized(self.language))
                                            .font(.custom("Urbanist-Bold", size: 34))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("Your saved images will appear here".localized(self.language))
                                            .font(.custom("Urbanist-Medium", size: 18))
                                            .foregroundColor(.white.opacity(0.7))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                        
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(hex: "#FC466B").opacity(0.5),
                                                        Color(hex: "#3F5EFB").opacity(0.5)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: 250, height: 1)
                                            .padding(.vertical, 10)
                                        
                                        Text("Start editing photos and save them to see them here".localized(self.language))
                                            .font(.custom("Urbanist-Regular", size: 16))
                                            .foregroundColor(.white.opacity(0.5))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 50)
                                        
                                        Spacer(minLength: 0)
                                    }
                                    .frame(minHeight: geometry.size.height - 200)
                                    .padding(.horizontal, 20)
                                }
                            } else {
                                ScrollView {
                                    LazyVGrid(columns: columns, spacing: gridSpacing) {
                                        ForEach(Array(savedImages.enumerated()), id: \.offset) { index, image in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: imageSize, height: imageSize)
                                                    .clipped()
                                                    .cornerRadius(12)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                    )
                                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                                
                                                Button(action: {
                                                    itemToDelete = index
                                                    deleteType = .savedPhotos
                                                    showDeleteAlert = true
                                                }) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.black.opacity(0.7))
                                                            .frame(width: 32, height: 32)
                                                        
                                                        Image(systemName: "trash.fill")
                                                            .font(.system(size: 16))
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                                .padding(8)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, gridSpacing)
                                }
                                .padding(.top, 10)
                                .padding(.bottom, Device.bottomSafeArea + 70)
                            }
                        } else {
                            // Videos Section
                            if savedVideos.isEmpty {
                                // Empty State View for Videos (Same style as Photos)
                                ScrollView {
                                    VStack(spacing: 25) {
                                        Spacer(minLength: 0)
                                        
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(hex: "#FC466B").opacity(0.3),
                                                            Color(hex: "#3F5EFB").opacity(0.3)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 160, height: 160)
                                                .scaleEffect(animateGradient ? 1.1 : 1.0)
                                            
                                            Circle()
                                                .fill(Color.white.opacity(0.1))
                                                .frame(width: 140, height: 140)
                                            
                                            Image(systemName: "video.fill")
                                                .font(.system(size: 60))
                                                .foregroundColor(.white)
                                                .shadow(color: .white.opacity(0.3), radius: 10)
                                        }
                                        
                                        Text("No Saved Videos".localized(self.language))
                                            .font(.custom("Urbanist-Bold", size: 34))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("Your saved videos will appear here".localized(self.language))
                                            .font(.custom("Urbanist-Medium", size: 18))
                                            .foregroundColor(.white.opacity(0.7))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                        
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(hex: "#FC466B").opacity(0.5),
                                                        Color(hex: "#3F5EFB").opacity(0.5)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: 250, height: 1)
                                            .padding(.vertical, 10)
                                        
                                        Text("Start editing videos and save them to see them here".localized(self.language))
                                            .font(.custom("Urbanist-Regular", size: 16))
                                            .foregroundColor(.white.opacity(0.5))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 50)
                                        
                                        Spacer(minLength: 0)
                                    }
                                    .frame(minHeight: geometry.size.height - 200)
                                    .padding(.horizontal, 20)
                                }
                            } else {
                                ScrollView {
                                    LazyVGrid(columns: columns, spacing: gridSpacing) {
                                        ForEach(Array(savedVideos.enumerated()), id: \.offset) { index, videoURL in
                                            ZStack(alignment: .topTrailing) {
                                                // Video Thumbnail
                                                VideoThumbnailView2(videoURL: videoURL, size: imageSize)
                                                    .onTapGesture {
                                                        // Play video in device player
                                                        let player = AVPlayer(url: videoURL)
                                                        let playerViewController = AVPlayerViewController()
                                                        playerViewController.player = player
                                                        
                                                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                                           let rootVC = windowScene.windows.first?.rootViewController {
                                                            rootVC.present(playerViewController, animated: true) {
                                                                player.play()
                                                            }
                                                        }
                                                    }
                                                
                                                // Menu Button (Save to Gallery + Delete)
                                                Button(action: {
                                                    itemToDelete = index
                                                    deleteType = .savedVideos
                                                    showDeleteAlert = true
                                                }) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.black.opacity(0.7))
                                                            .frame(width: 32, height: 32)
                                                        
                                                        Image(systemName: "ellipsis")
                                                            .font(.system(size: 16))
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                                .padding(8)
                                                .contextMenu {
                                                    Button(action: {
                                                        saveVideoToGallery(videoURL)
                                                    }) {
                                                        Label("Save to Gallery", systemImage: "square.and.arrow.down")
                                                    }
                                                    
                                                    Button(role: .destructive, action: {
                                                        itemToDelete = index
                                                        deleteType = .savedVideos
                                                        showDeleteAlert = true
                                                    }) {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, gridSpacing)
                                }
                                .padding(.top, 10)
                                .padding(.bottom, Device.bottomSafeArea + 70)
                            }
                        }
                    }
                }
                .onAppear {
                    loadSavedImages()
                    loadSavedVideos()
                    animateGradient = true
                }
                .alert(deleteType == .savedPhotos ? "Delete Image".localized(self.language) : "Delete Video".localized(self.language), isPresented: $showDeleteAlert) {
                    Button("Cancel".localized(self.language), role: .cancel) { }
                    Button("Delete".localized(self.language), role: .destructive) {
                        if let index = itemToDelete {
                            if deleteType == .savedPhotos {
                                deleteImage(at: index)
                            } else {
                                deleteVideo(at: index)
                            }
                        }
                    }
                } message: {
                    Text(deleteType == .savedPhotos ? "Are you sure you want to delete this image?".localized(self.language) : "Are you sure you want to delete this video?".localized(self.language))
                }
                .alert("Saved to Gallery", isPresented: $showSaveToGalleryAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Video has been saved to your photo library".localized(self.language))
                }
            }
        } else {
            // iPhone Layout
            ZStack {
                Image("app_bg_image")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // TopHomeView for iPhone
                    TopHomeView()
                        .padding(.top, UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .first?.windows
                            .first?.safeAreaInsets.top ?? 0)
                    
                    // Segment Control
                    segmentControlView
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    
                    if selectedSegment == .savedPhotos {
                        if savedImages.isEmpty {
                            // Existing Empty State View for Photos
                            ScrollView {
                                VStack(spacing: 25) {
                                    Spacer(minLength: 0)
                                    
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(hex: "#FC466B").opacity(0.3),
                                                        Color(hex: "#3F5EFB").opacity(0.3)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 140, height: 140)
                                            .scaleEffect(animateGradient ? 1.1 : 1.0)
                                        
                                        Circle()
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 120, height: 120)
                                        
                                        Image(systemName: "photo.stack")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white)
                                            .shadow(color: .white.opacity(0.3), radius: 10)
                                    }
                                    
                                    Text("No Saved Images".localized(self.language))
                                        .font(.custom("Urbanist-Bold", size: 24))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Your saved images will appear here".localized(self.language))
                                        .font(.custom("Urbanist-Medium", size: 16))
                                        .foregroundColor(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                    
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "#FC466B").opacity(0.5),
                                                    Color(hex: "#3F5EFB").opacity(0.5)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: 200, height: 1)
                                        .padding(.vertical, 10)
                                    
                                    Spacer(minLength: 0)
                                }
                                .frame(minHeight: UIScreen.main.bounds.height - 200)
                                .padding(.horizontal, 20)
                            }
                        } else {
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: gridSpacing) {
                                    ForEach(Array(savedImages.enumerated()), id: \.offset) { index, image in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: imageSize, height: imageSize)
                                                .clipped()
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                )
                                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                            
                                            Button(action: {
                                                itemToDelete = index
                                                deleteType = .savedPhotos
                                                showDeleteAlert = true
                                            }) {
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.black.opacity(0.7))
                                                        .frame(width: 28, height: 28)
                                                    
                                                    Image(systemName: "trash.fill")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            .padding(6)
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, gridSpacing)
                            }
                            .padding(.top, 10)
                            .padding(.bottom, Device.bottomSafeArea + 70)
                        }
                    } else {
                        // Videos Section for iPhone
                        if savedVideos.isEmpty {
                            ScrollView {
                                VStack(spacing: 25) {
                                    Spacer(minLength: 0)
                                    
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(hex: "#FC466B").opacity(0.3),
                                                        Color(hex: "#3F5EFB").opacity(0.3)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 140, height: 140)
                                            .scaleEffect(animateGradient ? 1.1 : 1.0)
                                        
                                        Circle()
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 120, height: 120)
                                        
                                        Image(systemName: "video.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white)
                                            .shadow(color: .white.opacity(0.3), radius: 10)
                                    }
                                    
                                    Text("No Saved Videos".localized(self.language))
                                        .font(.custom("Urbanist-Bold", size: 24))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Your saved videos will appear here".localized(self.language))
                                        .font(.custom("Urbanist-Medium", size: 16))
                                        .foregroundColor(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                    
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "#FC466B").opacity(0.5),
                                                    Color(hex: "#3F5EFB").opacity(0.5)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: 200, height: 1)
                                        .padding(.vertical, 10)
                                    
                                    Spacer(minLength: 0)
                                }
                                .frame(minHeight: UIScreen.main.bounds.height - 200)
                                .padding(.horizontal, 20)
                            }
                        } else {
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: gridSpacing) {
                                    ForEach(Array(savedVideos.enumerated()), id: \.offset) { index, videoURL in
                                        ZStack(alignment: .topTrailing) {
                                            VideoThumbnailView2(videoURL: videoURL, size: imageSize)
                                                .onTapGesture {
                                                    let player = AVPlayer(url: videoURL)
                                                    let playerViewController = AVPlayerViewController()
                                                    playerViewController.player = player
                                                    
                                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                                       let rootVC = windowScene.windows.first?.rootViewController {
                                                        rootVC.present(playerViewController, animated: true) {
                                                            player.play()
                                                        }
                                                    }
                                                }
                                            
                                            Button(action: {
                                                itemToDelete = index
                                                deleteType = .savedVideos
                                                showDeleteAlert = true
                                            }) {
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.black.opacity(0.7))
                                                        .frame(width: 28, height: 28)
                                                    
                                                    Image(systemName: "ellipsis")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            .padding(6)
                                            .contextMenu {
                                                Button(action: {
                                                    saveVideoToGallery(videoURL)
                                                }) {
                                                    Label("Save to Gallery", systemImage: "square.and.arrow.down")
                                                }
                                                
                                                Button(role: .destructive, action: {
                                                    itemToDelete = index
                                                    deleteType = .savedVideos
                                                    showDeleteAlert = true
                                                }) {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, gridSpacing)
                            }
                            .padding(.top, 10)
                            .padding(.bottom, Device.bottomSafeArea + 70)
                        }
                    }
                }
            }
            .onAppear {
                loadSavedImages()
                loadSavedVideos()
                animateGradient = true
            }
            .alert(deleteType == .savedPhotos ? "Delete Image".localized(self.language) : "Delete Video".localized(self.language), isPresented: $showDeleteAlert) {
                Button("Cancel".localized(self.language), role: .cancel) { }
                Button("Delete".localized(self.language), role: .destructive) {
                    if let index = itemToDelete {
                        if deleteType == .savedPhotos {
                            deleteImage(at: index)
                        } else {
                            deleteVideo(at: index)
                        }
                    }
                }
            } message: {
                Text(deleteType == .savedPhotos ? "Are you sure you want to delete this image?".localized(self.language) : "Are you sure you want to delete this video?".localized(self.language))
            }
            .alert("Saved to Gallery", isPresented: $showSaveToGalleryAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Video has been saved to your photo library".localized(self.language))
            }
        }
    }
    
    // MARK: - Segment Control View
    private var segmentControlView: some View {
        HStack(spacing: 0) {
            ForEach(SavedAssetsType.allCases, id: \.self) { type in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSegment = type
                    }
                }) {
                    Text(type.rawValue.localized(self.language))
                        .font(.custom("Urbanist-SemiBold", size: Device.isIpad ? 18 : 16))
                        .foregroundColor(selectedSegment == type ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(selectedSegment == type ? Color.blue : Color.clear)
                        )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    // MARK: - Load Methods
    private func loadSavedImages() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let savedImagesPath = documentsPath.appendingPathComponent("SavedImages")
        
        guard fileManager.fileExists(atPath: savedImagesPath.path) else { return }
        
        do {
            let imageFiles = try fileManager.contentsOfDirectory(at: savedImagesPath, includingPropertiesForKeys: nil)
            var images: [UIImage] = []
            
            for file in imageFiles {
                if let image = UIImage(contentsOfFile: file.path) {
                    images.append(image)
                }
            }
            savedImages = images
        } catch {
            print("Error loading images: \(error)")
        }
    }
    
    private func loadSavedVideos() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let savedVideosPath = documentsPath.appendingPathComponent("SavedVideos")
        
        guard fileManager.fileExists(atPath: savedVideosPath.path) else { return }
        
        do {
            let videoFiles = try fileManager.contentsOfDirectory(at: savedVideosPath, includingPropertiesForKeys: nil)
            var videos: [URL] = []
            
            for file in videoFiles {
                if file.pathExtension.lowercased() == "mp4" {
                    videos.append(file)
                }
            }
            savedVideos = videos
        } catch {
            print("Error loading videos: \(error)")
        }
    }
    
    // MARK: - Delete Methods
    private func deleteImage(at index: Int) {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let savedImagesPath = documentsPath.appendingPathComponent("SavedImages")
        
        do {
            let imageFiles = try fileManager.contentsOfDirectory(at: savedImagesPath, includingPropertiesForKeys: nil)
            if index < imageFiles.count {
                try fileManager.removeItem(at: imageFiles[index])
                savedImages.remove(at: index)
            }
        } catch {
            print("Error deleting image: \(error)")
        }
    }
    
    private func deleteVideo(at index: Int) {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let savedVideosPath = documentsPath.appendingPathComponent("SavedVideos")
        
        do {
            let videoFiles = try fileManager.contentsOfDirectory(at: savedVideosPath, includingPropertiesForKeys: nil)
            let mp4Files = videoFiles.filter { $0.pathExtension.lowercased() == "mp4" }
            if index < mp4Files.count {
                try fileManager.removeItem(at: mp4Files[index])
                savedVideos.remove(at: index)
            }
        } catch {
            print("Error deleting video: \(error)")
        }
    }
    
    // MARK: - Save Video to Gallery
    private func saveVideoToGallery(_ videoURL: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            showSaveToGalleryAlert = true
                        } else {
                            print("Error saving video: \(error?.localizedDescription ?? "unknown error")")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Video Thumbnail View
struct VideoThumbnailView2: View {
    let videoURL: URL
    let size: CGFloat
    @State private var thumbnail: UIImage?
    @State private var duration: String = ""
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipped()
                    .cornerRadius(Device.isIpad ? 12 : 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: Device.isIpad ? 12 : 8)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                    .cornerRadius(Device.isIpad ? 12 : 8)
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            }
            
            // Duration label
            Text(duration)
                .font(.custom("Urbanist-Medium", size: Device.isIpad ? 12 : 10))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.7))
                .cornerRadius(4)
                .padding(6)
            
            // Play icon
            Image(systemName: "play.circle.fill")
                .font(.system(size: Device.isIpad ? 30 : 24))
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black, radius: 2)
                .padding(6)
        }
        .onAppear {
            loadThumbnail()
            loadDuration()
        }
    }
    
    private func loadThumbnail() {
        let asset = AVAsset(url: videoURL)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let cgImage = try assetGenerator.copyCGImage(at: time, actualTime: nil)
            thumbnail = UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
        }
    }
    
    private func loadDuration() {
        let asset = AVAsset(url: videoURL)
        let durationInSeconds = asset.duration.seconds
        let minutes = Int(durationInSeconds) / 60
        let seconds = Int(durationInSeconds) % 60
        duration = String(format: "%02d:%02d", minutes, seconds)
    }
}

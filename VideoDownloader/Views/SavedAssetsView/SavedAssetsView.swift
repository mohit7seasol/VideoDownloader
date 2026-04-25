//
//  SavedAssetsView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 25/04/26.
//

import SwiftUI
import AVKit
import Photos

enum SavedAssetsType: String, CaseIterable {
    case savedPhotos = "Photos"
    case savedVideos = "Videos"
    
    var localizedTitle: String {
        switch self {
        case .savedPhotos:
            return "Photos".localized(LocalizationService.shared.language)
        case .savedVideos:
            return "Videos".localized(LocalizationService.shared.language)
        }
    }
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
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var refreshID = UUID() // Add this to force refresh
    
    // Dynamic columns based on device with equal spacing
    private var columns: [GridItem] {
        if Device.isIpad {
            return Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)
        } else {
            return Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
        }
    }
    
    private var gridSpacing: CGFloat {
        Device.isIpad ? 12 : 8
    }
    
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
                        TopHomeView()
                            .padding(.top, UIApplication.shared.connectedScenes
                                .compactMap { $0 as? UIWindowScene }
                                .first?.windows
                                .first?.safeAreaInsets.top ?? 0)
                        
                        segmentControlView
                            .padding(.horizontal, 24)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        
                        if selectedSegment == .savedPhotos {
                            if savedImages.isEmpty {
                                emptyStateView(
                                    icon: "photo.stack",
                                    title: "No Saved Images".localized(language),
                                    subtitle: "Your saved images will appear here".localized(language),
                                    message: "Start editing photos and save them to see them here".localized(language),
                                    size: 60
                                )
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
                                                
                                                Menu {
                                                    Button(action: {
                                                        shareImage(image)
                                                    }) {
                                                        Label("Share".localized(language), systemImage: "square.and.arrow.up")
                                                    }
                                                    
                                                    Button(action: {
                                                        saveImageToGallery(image)
                                                    }) {
                                                        Label("Save to Gallery".localized(language), systemImage: "square.and.arrow.down")
                                                    }
                                                    
                                                    Button(role: .destructive, action: {
                                                        itemToDelete = index
                                                        deleteType = .savedPhotos
                                                        showDeleteAlert = true
                                                    }) {
                                                        Label("Delete".localized(language), systemImage: "trash")
                                                    }
                                                } label: {
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
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, gridSpacing)
                                }
                                .padding(.top, 10)
                                .padding(.bottom, Device.bottomSafeArea + 70)
                                .id(refreshID) // Add id to force refresh
                            }
                        } else {
                            if savedVideos.isEmpty {
                                emptyStateView(
                                    icon: "video.slash",
                                    title: "No Saved Videos".localized(language),
                                    subtitle: "Your saved videos will appear here".localized(language),
                                    message: "Start editing videos and save them to see them here".localized(language),
                                    size: 60
                                )
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
                                                
                                                Menu {
                                                    Button(action: {
                                                        shareVideo(videoURL)
                                                    }) {
                                                        Label("Share".localized(language), systemImage: "square.and.arrow.up")
                                                    }
                                                    
                                                    Button(action: {
                                                        saveVideoToGallery(videoURL)
                                                    }) {
                                                        Label("Save to Gallery".localized(language), systemImage: "square.and.arrow.down")
                                                    }
                                                    
                                                    Button(role: .destructive, action: {
                                                        itemToDelete = index
                                                        deleteType = .savedVideos
                                                        showDeleteAlert = true
                                                    }) {
                                                        Label("Delete".localized(language), systemImage: "trash")
                                                    }
                                                } label: {
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
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, gridSpacing)
                                }
                                .padding(.top, 10)
                                .padding(.bottom, Device.bottomSafeArea + 70)
                                .id(refreshID) // Add id to force refresh
                            }
                        }
                    }
                }
                .onAppear {
                    loadSavedImages()
                    loadSavedVideos()
                    animateGradient = true
                }
                .alert(deleteType == .savedPhotos ? "Delete Image".localized(language) : "Delete Video".localized(language), isPresented: $showDeleteAlert) {
                    Button("Cancel".localized(language), role: .cancel) { }
                    Button("Delete".localized(language), role: .destructive) {
                        if let index = itemToDelete {
                            if deleteType == .savedPhotos {
                                deleteImage(at: index)
                            } else {
                                deleteVideo(at: index)
                            }
                        }
                        itemToDelete = nil
                    }
                } message: {
                    Text(deleteType == .savedPhotos ? "Are you sure you want to delete this image?".localized(language) : "Are you sure you want to delete this video?".localized(language))
                }
                .alert("Saved to Gallery".localized(language), isPresented: $showSaveToGalleryAlert) {
                    Button("OK".localized(language), role: .cancel) { }
                } message: {
                    Text("Media has been saved to your photo library".localized(language))
                }
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet2(activityItems: shareItems)
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
                    TopHomeView()
                        .padding(.top, UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .first?.windows
                            .first?.safeAreaInsets.top ?? 0)
                    
                    segmentControlView
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    
                    if selectedSegment == .savedPhotos {
                        if savedImages.isEmpty {
                            emptyStateView(
                                icon: "photo.stack",
                                title: "No Saved Images".localized(language),
                                subtitle: "Your saved images will appear here".localized(language),
                                message: "",
                                size: 50
                            )
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
                                            
                                            Menu {
                                                Button(action: {
                                                    shareImage(image)
                                                }) {
                                                    Label("Share".localized(language), systemImage: "square.and.arrow.up")
                                                }
                                                
                                                Button(action: {
                                                    saveImageToGallery(image)
                                                }) {
                                                    Label("Save to Gallery".localized(language), systemImage: "square.and.arrow.down")
                                                }
                                                
                                                Button(role: .destructive, action: {
                                                    itemToDelete = index
                                                    deleteType = .savedPhotos
                                                    showDeleteAlert = true
                                                }) {
                                                    Label("Delete".localized(language), systemImage: "trash")
                                                }
                                            } label: {
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
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, gridSpacing)
                            }
                            .padding(.top, 10)
                            .padding(.bottom, Device.bottomSafeArea + 70)
                            .id(refreshID) // Add id to force refresh
                        }
                    } else {
                        if savedVideos.isEmpty {
                            emptyStateView(
                                icon: "video.slash",
                                title: "No Saved Videos".localized(language),
                                subtitle: "Your saved videos will appear here".localized(language),
                                message: "",
                                size: 50
                            )
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
                                            
                                            Menu {
                                                Button(action: {
                                                    shareVideo(videoURL)
                                                }) {
                                                    Label("Share".localized(language), systemImage: "square.and.arrow.up")
                                                }
                                                
                                                Button(action: {
                                                    saveVideoToGallery(videoURL)
                                                }) {
                                                    Label("Save to Gallery".localized(language), systemImage: "square.and.arrow.down")
                                                }
                                                
                                                Button(role: .destructive, action: {
                                                    itemToDelete = index
                                                    deleteType = .savedVideos
                                                    showDeleteAlert = true
                                                }) {
                                                    Label("Delete".localized(language), systemImage: "trash")
                                                }
                                            } label: {
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
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, gridSpacing)
                            }
                            .padding(.top, 10)
                            .padding(.bottom, Device.bottomSafeArea + 70)
                            .id(refreshID) // Add id to force refresh
                        }
                    }
                }
            }
            .onAppear {
                loadSavedImages()
                loadSavedVideos()
                animateGradient = true
            }
            .alert(deleteType == .savedPhotos ? "Delete Image".localized(language) : "Delete Video".localized(language), isPresented: $showDeleteAlert) {
                Button("Cancel".localized(language), role: .cancel) { }
                Button("Delete".localized(language), role: .destructive) {
                    if let index = itemToDelete {
                        if deleteType == .savedPhotos {
                            deleteImage(at: index)
                        } else {
                            deleteVideo(at: index)
                        }
                    }
                    itemToDelete = nil
                }
            } message: {
                Text(deleteType == .savedPhotos ? "Are you sure you want to delete this image?".localized(language) : "Are you sure you want to delete this video?".localized(language))
            }
            .alert("Saved to Gallery".localized(language), isPresented: $showSaveToGalleryAlert) {
                Button("OK".localized(language), role: .cancel) { }
            } message: {
                Text("Media has been saved to your photo library".localized(language))
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet2(activityItems: shareItems)
            }
        }
    }
    
    // MARK: - Empty State View
    private func emptyStateView(icon: String, title: String, subtitle: String, message: String, size: CGFloat) -> some View {
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
                        .frame(width: Device.isIpad ? 160 : 140, height: Device.isIpad ? 160 : 140)
                        .scaleEffect(animateGradient ? 1.1 : 1.0)
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: Device.isIpad ? 140 : 120, height: Device.isIpad ? 140 : 120)
                    
                    Image(systemName: icon)
                        .font(.system(size: size))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.3), radius: 10)
                }
                
                Text(title.localized(self.language))
                    .font(.custom("Urbanist-Bold", size: Device.isIpad ? 34 : 24))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(subtitle.localized(self.language))
                    .font(.custom("Urbanist-Medium", size: Device.isIpad ? 18 : 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Device.isIpad ? 40 : 20)
                
                if !message.isEmpty {
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
                        .frame(width: Device.isIpad ? 250 : 200, height: 1)
                        .padding(.vertical, 10)
                    
                    Text(message.localized(self.language))
                        .font(.custom("Urbanist-Regular", size: Device.isIpad ? 16 : 14))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Device.isIpad ? 50 : 30)
                }
                
                Spacer(minLength: 0)
            }
            .frame(minHeight: Device.isIpad ? UIScreen.main.bounds.height - 200 : UIScreen.main.bounds.height - 200)
            .padding(.horizontal, 20)
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
                    Text(type.localizedTitle)
                        .font(.custom("Urbanist-SemiBold", size: Device.isIpad ? 18 : 16))
                        .foregroundColor(selectedSegment == type ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Group {
                                if selectedSegment == type {
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "#1973E8"),
                                                    Color(hex: "#0E4082")
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                } else {
                                    Color.clear
                                }
                            }
                        )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    // MARK: - Share Methods
    private func shareImage(_ image: UIImage) {
        shareItems = [image]
        showShareSheet = true
    }
    
    private func shareVideo(_ videoURL: URL) {
        shareItems = [videoURL]
        showShareSheet = true
    }
    
    // MARK: - Save to Gallery Methods
    private func saveImageToGallery(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            showSaveToGalleryAlert = true
                        } else {
                            print("Error saving image: \(error?.localizedDescription ?? "unknown error")")
                        }
                    }
                }
            }
        }
    }
    
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
    
    // MARK: - Load Methods (with sorting - newest first)
    private func loadSavedImages() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let savedImagesPath = documentsPath.appendingPathComponent("SavedImages")
        
        guard fileManager.fileExists(atPath: savedImagesPath.path) else { return }
        
        do {
            let imageFiles = try fileManager.contentsOfDirectory(at: savedImagesPath, includingPropertiesForKeys: [.creationDateKey])
            var imagesWithDate: [(image: UIImage, date: Date, url: URL)] = []
            
            for file in imageFiles {
                if let image = UIImage(contentsOfFile: file.path) {
                    let attributes = try fileManager.attributesOfItem(atPath: file.path)
                    let creationDate = attributes[.creationDate] as? Date ?? Date.distantPast
                    imagesWithDate.append((image: image, date: creationDate, url: file))
                }
            }
            
            // Sort by creation date (newest first)
            imagesWithDate.sort { $0.date > $1.date }
            
            savedImages = imagesWithDate.map { $0.image }
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
            let videoFiles = try fileManager.contentsOfDirectory(at: savedVideosPath, includingPropertiesForKeys: [.creationDateKey])
            var videosWithDate: [(url: URL, date: Date)] = []
            
            for file in videoFiles {
                if file.pathExtension.lowercased() == "mp4" {
                    let attributes = try fileManager.attributesOfItem(atPath: file.path)
                    let creationDate = attributes[.creationDate] as? Date ?? Date.distantPast
                    videosWithDate.append((url: file, date: creationDate))
                }
            }
            
            // Sort by creation date (newest first)
            videosWithDate.sort { $0.date > $1.date }
            
            savedVideos = videosWithDate.map { $0.url }
        } catch {
            print("Error loading videos: \(error)")
        }
    }
    
    // MARK: - Delete Methods (Fixed - deletes correct item and reloads)
    private func deleteImage(at index: Int) {
        guard index < savedImages.count else { return }
        
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let savedImagesPath = documentsPath.appendingPathComponent("SavedImages")
        
        do {
            // Get sorted files to match the displayed order
            let imageFiles = try fileManager.contentsOfDirectory(at: savedImagesPath, includingPropertiesForKeys: [.creationDateKey])
            var filesWithDate: [(url: URL, date: Date)] = []
            
            for file in imageFiles {
                let attributes = try fileManager.attributesOfItem(atPath: file.path)
                let creationDate = attributes[.creationDate] as? Date ?? Date.distantPast
                filesWithDate.append((url: file, date: creationDate))
            }
            
            // Sort by creation date (newest first) to match display order
            filesWithDate.sort { $0.date > $1.date }
            
            if index < filesWithDate.count {
                try fileManager.removeItem(at: filesWithDate[index].url)
                
                // Reload the images array
                loadSavedImages()
                
                // Force view refresh
                refreshID = UUID()
            }
        } catch {
            print("Error deleting image: \(error)")
        }
    }
    
    private func deleteVideo(at index: Int) {
        guard index < savedVideos.count else { return }
        
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let savedVideosPath = documentsPath.appendingPathComponent("SavedVideos")
        
        do {
            // Get sorted files to match the displayed order
            let videoFiles = try fileManager.contentsOfDirectory(at: savedVideosPath, includingPropertiesForKeys: [.creationDateKey])
            var filesWithDate: [(url: URL, date: Date)] = []
            
            for file in videoFiles {
                if file.pathExtension.lowercased() == "mp4" {
                    let attributes = try fileManager.attributesOfItem(atPath: file.path)
                    let creationDate = attributes[.creationDate] as? Date ?? Date.distantPast
                    filesWithDate.append((url: file, date: creationDate))
                }
            }
            
            // Sort by creation date (newest first) to match display order
            filesWithDate.sort { $0.date > $1.date }
            
            if index < filesWithDate.count {
                try fileManager.removeItem(at: filesWithDate[index].url)
                
                // Reload the videos array
                loadSavedVideos()
                
                // Force view refresh
                refreshID = UUID()
            }
        } catch {
            print("Error deleting video: \(error)")
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet2: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
            
            // Play icon on left side
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: Device.isIpad ? 30 : 24))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black, radius: 2)

                Spacer()
            }
            .padding(6)

            // Duration bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(duration)
                        .font(.custom("Urbanist-Medium", size: Device.isIpad ? 12 : 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                }
            }
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

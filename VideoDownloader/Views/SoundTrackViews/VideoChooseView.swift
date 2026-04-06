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
import Combine

// MARK: - VideoChooseView
struct VideoChooseView: View {
    @Environment(\.dismiss) var dismiss
    @State private var videos: [VideoAsset] = []
    @State private var isLoading = false
    @State private var selectedVideo: VideoAsset?
    @State private var navigateToAddMusic = false
    @State private var showPermissionAlert = false
    @State private var showManageOptions = false
    @State private var showPhotoPicker = false
    @State private var showLimitedAccessBottomSheet = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    @StateObject private var photoObserver = PhotoLibraryObserver()
    
//    let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "App"
    
    var body: some View {
        if Device.isIpad {
            GeometryReader { geometry in
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
                            
                            Text("Select Video".localized(self.language))
                                .font(.custom("Poppins-Black", size: 20))
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 60)
                        
                        // Limited Access Message - Only show when limited access
                        if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
                            LimitAccessView(appName: appName)
                        }
                        
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
                            // Video Grid
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
                                .padding(.top, 10)
                                .padding(.bottom, 30)
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    photoObserver.onChange = {
                        loadVideos()
                    }
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
                // Manage Options Alert - Matches uploaded image style
                .alert("Manage", isPresented: $showManageOptions) {
                    Button("Select More Videos") {
                        showPhotoPicker = true
                    }
                    
                    Button("Change Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("You've given \(appName) limited access to select number of videos")
                }
                // PHPicker for selecting more media
                .photosPicker(
                    isPresented: $showPhotoPicker,
                    selection: $selectedItems,
                    maxSelectionCount: nil,
                    matching: .videos,
                    preferredItemEncoding: .automatic
                )
                .onChange(of: selectedItems) { newItems in
                    if !newItems.isEmpty {
                        handleSelectedPhotosPickerItems(newItems)
                    }
                }
                .navigationDestination(isPresented: $navigateToAddMusic) {
                    if let video = selectedVideo {
                        AddMusicToVideoView(videoAsset: video)
                    }
                }
            }
            .ignoresSafeArea()
        } else {
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
                        
                        Text("Select Video".localized(self.language))
                            .font(.custom("Poppins-Black", size: 20))
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    
                    // Limited Access Message - Only show when limited access
                    if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
                        LimitAccessView(appName: appName)
                    }
                    
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
                        // Video Grid
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
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                photoObserver.onChange = {
                    loadVideos()
                }
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
            // Manage Options Alert - Matches uploaded image style
            .alert("Manage", isPresented: $showManageOptions) {
                Button("Select More Videos") {
                    showPhotoPicker = true
                }
                
                Button("Change Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You've given \(appName) limited access to select number of videos")
            }
            // PHPicker for selecting more media
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedItems,
                maxSelectionCount: nil,
                matching: .videos,
                preferredItemEncoding: .automatic
            )
            .onChange(of: selectedItems) { newItems in
                if !newItems.isEmpty {
                    handleSelectedPhotosPickerItems(newItems)
                }
            }
            .navigationDestination(isPresented: $navigateToAddMusic) {
                if let video = selectedVideo {
                    AddMusicToVideoView(videoAsset: video)
                }
            }
        }
    }
    
    private func handleSelectedPhotosPickerItems(_ items: [PhotosPickerItem]) {
        // Process and add new videos from picker
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        // Save video data if needed
                        DispatchQueue.main.async {
                            // Reload videos after a short delay to allow for processing
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                loadVideos()
                            }
                        }
                    }
                case .failure(let error):
                    print("Error loading video: \(error)")
                }
            }
        }
        
        // Clear selected items
        DispatchQueue.main.async {
            self.selectedItems = []
        }
    }
    
    private func checkPermissionAndLoadVideos() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            loadVideos()

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        loadVideos()
                    } else {
                        showPermissionAlert = true
                    }
                }
            }

        case .denied, .restricted:
            showPermissionAlert = true

        @unknown default:
            break
        }
    }
    
    private func loadVideos() {
        isLoading = true

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)

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

// MARK: - LimitAccessView
struct LimitAccessView: View {
    let appName: String
    @State private var showManageOptions = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Select Video".localized(self.language))
                    .font(.custom("Urbanist-Medium", size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Button {
                    showManageOptions = true
                } label: {
                    Text("Manage".localized(self.language))
                        .font(.custom("Urbanist-Medium", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(12)
                }
            }
            
            Text("\("You've given".localized(self.language)) \(appName) \("limited access to select number of videos".localized(self.language))")
                .font(.custom("Urbanist-Medium", size: 13))
                .foregroundColor(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .alert("Manage".localized(self.language), isPresented: $showManageOptions) {
            Button("Select More Videos".localized(self.language)) {
                // Handle select more videos
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    
                    PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: rootViewController)
                }
            }
            
            Button("Change Settings".localized(self.language)) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Cancel".localized(self.language), role: .cancel) { }
        } message: {
            Text("\("You've given".localized(self.language)) \(appName) \("limited access to select number of videos".localized(self.language))")
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
            
            // Duration label
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
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestImage(
            for: video.asset,
            targetSize: CGSize(width: 300, height: 300),
            contentMode: .aspectFill,
            options: options
        ) { image, info in
            guard let image = image else { return }

            DispatchQueue.main.async {
                self.thumbnail = image
            }
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

class PhotoLibraryObserver: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    
    var onChange: (() -> Void)?
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.onChange?()
        }
    }
}

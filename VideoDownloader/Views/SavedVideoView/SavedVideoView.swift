//
//  SavedVideoView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import SwiftUI
import AVFoundation
import Photos

struct SavedVideoView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = HistoryViewModel()
    @StateObject private var folderManager = FolderManager.shared
    @State private var selectedVideo: SavedVideo?
    @State private var showFullVideoView = false
    @State private var selectedFolder: VideoFolder?
    @State private var showFolderContent = false
    @State private var showDeleteFolderAlert = false
    @State private var folderToDelete: VideoFolder?
    @State private var showRenameFolderAlert = false
    @State private var folderToRename: VideoFolder?
    @State private var newFolderName = ""
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    private let columns: [GridItem] = {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let count = isIPad ? 4 : 3 // 3 columns for folders
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
    }()
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        GeometryReader { geometry in
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
                    // Top View with Back Button and Title
                    HStack {
//                        Image("app_logo")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(
//                                width: isIpad ? 140 : 120,
//                                height: isIpad ? 42 : 32
//                            )
//                        
//                        Spacer()
                        
                        // Create Folder Button - Only show when folders exist
                        if !folderManager.folders.isEmpty {
                            Image("app_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: isIpad ? 140 : 120,
                                    height: isIpad ? 42 : 32
                                )
                            Spacer()
                            
                            Button(action: {
                                showRenameFolderAlert = true
                                newFolderName = ""
                                folderToRename = nil
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .medium))
                                    .frame(width: 26, height: 26) // Increased tap area
                                    .contentShape(Rectangle())
                            }
                        } else {
                            
                            Image("app_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: isIpad ? 140 : 120,
                                    height: isIpad ? 42 : 32
                                )
                                .padding(.bottom, 12)
                            Spacer()
                            
                            // Empty view for balance when no folders
                            Color.clear
                                .frame(width: 44, height: 44)
                            
                            NavigationLink(destination: SettingView()) {
                                Image("setting_ic")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: isIpad ? 36 : 26,
                                        height: isIpad ? 36 : 26
                                    )
                                    .padding(.trailing, 5)
                                    .padding(.top, -12)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .first?.windows
                        .first?.safeAreaInsets.top ?? 0)
                    
                    // Folders Grid or Empty State
                    if folderManager.folders.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "folder")
                                .font(.system(size: 70))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("No Folders Yet".localized(language))
                                .font(.custom("Urbanist-Bold", size: 22))
                                .foregroundColor(.white)
                            
                            Text("Create your first folder to organize videos".localized(language))
                                .font(.custom("Urbanist-Medium", size: 16))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Button(action: {
                                showRenameFolderAlert = true
                                newFolderName = ""
                                folderToRename = nil
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create Folder".localized(language))
                                        .font(.custom("Urbanist-Bold", size: 16))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#1973E8"),
                                            Color(hex: "#0E4082")
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(25)
                            }
                            .shadow(
                                color: Color(hex: "#1973E8").opacity(0.3),
                                radius: 10,
                                x: 0,
                                y: 6
                            )
                        }
                        .padding(.bottom, 100)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(folderManager.folders) { folder in
                                    FolderViewCard(
                                        folder: folder,
                                        videoCount: folderManager.getVideosForFolder(folderId: folder.id).count,
                                        onTap: {
                                            selectedFolder = folder
                                            showFolderContent = true
                                        },
                                        onDelete: {
                                            folderToDelete = folder
                                            showDeleteFolderAlert = true
                                        },
                                        onRename: {
                                            folderToRename = folder
                                            newFolderName = folder.name
                                            showRenameFolderAlert = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                        }
                        .refreshable {
                            // Refresh downloads folder data
                            if let downloadsFolder = folderManager.folders.first(where: { $0.isSystemFolder && $0.name == "Downloads" }) {
                                folderManager.loadDeviceVideos(forceRefresh: true)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showFolderContent) {
            if let folder = selectedFolder {
                FolderContentView(folder: folder)
            }
        }
        .navigationDestination(isPresented: $showFullVideoView) {
            if let video = selectedVideo {
                FullVideoView(video: video)
            }
        }
        .alert("Delete Folder".localized(language), isPresented: $showDeleteFolderAlert) {
            Button("Cancel".localized(language), role: .cancel) { }
            Button("Delete".localized(language), role: .destructive) {
                if let folder = folderToDelete {
                    folderManager.deleteFolder(folderId: folder.id)
                }
            }
        } message: {
            if let folder = folderToDelete {
                Text("\("Are you sure you want to delete folder".localized(language)) \"\(folder.name)\"? \("Videos inside will not be deleted.".localized(language))")
                    .font(.custom("Urbanist-Medium", size: 16))
            } else {
                Text("Are you sure you want to delete this folder?".localized(language))
            }
        }
        .alert(folderToRename == nil ? "Create New Folder".localized(language) : "Rename Folder".localized(language),
               isPresented: $showRenameFolderAlert) {
            TextField("Folder Name".localized(language), text: $newFolderName)
                .textInputAutocapitalization(.words)
            
            Button("Cancel".localized(language), role: .cancel) {
                newFolderName = ""
                folderToRename = nil
            }
            
            Button(folderToRename == nil ? "Create".localized(language) : "Rename".localized(language)) {
                if !newFolderName.isEmpty {
                    if let folder = folderToRename {
                        folderManager.renameFolder(folderId: folder.id, newName: newFolderName)
                    } else {
                        folderManager.createFolder(name: newFolderName)
                    }
                    newFolderName = ""
                    folderToRename = nil
                }
            }
        } message: {
            if folderToRename == nil {
                Text("Enter a name for your new folder".localized(language))
            } else {
                Text("Enter new name for the folder".localized(language))
            }
        }
        .onAppear {
            folderManager.loadFolders()
            // Ensure Downloads folder is at the top
            if let downloadsIndex = folderManager.folders.firstIndex(where: { $0.isSystemFolder && $0.name == "Downloads" }), downloadsIndex != 0 {
                let downloadsFolder = folderManager.folders.remove(at: downloadsIndex)
                folderManager.folders.insert(downloadsFolder, at: 0)
                folderManager.saveFolders()
            }
        }
    }
}

// MARK: - Folder Content View
struct FolderContentView: View {
    let folder: VideoFolder
    @StateObject private var folderManager = FolderManager.shared
    @State private var videos: [SavedVideo] = []
    @State private var deviceVideos: [DeviceVideo] = []
    @State private var selectedVideo: SavedVideo?
    @State private var selectedDeviceVideo: DeviceVideo?
    @State private var showFullVideoView = false
    @State private var showDeviceVideoView = false
    @Environment(\.dismiss) var dismiss
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    @State private var isLoading = false
    @State private var loadTask: DispatchWorkItem?
    
    // ✅ App Name for LimitAccessView
    let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "App"
    
    // Delete video states
    @State private var showDeleteVideoAlert = false
    @State private var videoToDelete: SavedVideo?
    
    // Responsive columns
    private let columns: [GridItem] = {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let count = isIPad ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
    }()
    
    var body: some View {
        ZStack {
            Image("app_bg_image")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
            VStack {
                
                // MARK: - HEADER (UNCHANGED)
                HStack {
                    Button(action: {
                        cancelLoadTask()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                            .padding(.leading, 4)
                    }
                    
                    Spacer()
                    
                    Text(folder.name)
                        .font(.custom("Urbanist-Bold", size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    if folder.isDeviceVideos && !deviceVideos.isEmpty {
                        Button(action: {
                            refreshDeviceVideos()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                                .frame(width: 30, height: 30)
                        }
                    } else {
                        Color.clear.frame(width: 60, height: 20)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first?.windows
                    .first?.safeAreaInsets.top ?? 0)
                
                // ✅ LIMITED ACCESS VIEW (NEW - SAFE)
                if folder.isDeviceVideos &&
                    PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
                    
                    LimitAccessView(appName: appName)
                        .padding(.top, 10)
                }
                
                // MARK: - STATES
                
                // Loading State
                if folderManager.isScanningVideos && folder.isDeviceVideos {
                    Spacer()
                    VStack(spacing: 20) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        
                        Text("Loading videos...".localized(language))
                            .font(.custom("Urbanist-Medium", size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                }
                
                // Permission Denied
                else if folder.isDeviceVideos && VideoScanner.shared.permissionDenied {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Text("Permission Denied".localized(language))
                            .font(.custom("Urbanist-Bold", size: 20))
                            .foregroundColor(.white)
                        
                        Text("Please allow access to your photos and videos in Settings".localized(language))
                            .font(.custom("Urbanist-Medium", size: 16))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Open Settings".localized(language))
                                .font(.custom("Urbanist-Bold", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background(Color.blue)
                                .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    Spacer()
                }
                
                // Empty Device Videos
                else if folder.isDeviceVideos && deviceVideos.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Text("No Videos Found".localized(language))
                            .font(.custom("Urbanist-Bold", size: 20))
                            .foregroundColor(.white)
                        
                        Text(
                            PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited
                            ? "Only selected videos are visible. You can manage access.".localized(language)
                            : "No videos found in your device gallery".localized(language)
                        )
                        .font(.custom("Urbanist-Medium", size: 16))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    Spacer()
                }
                
                // Empty Folder
                else if !folder.isDeviceVideos && videos.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "folder")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Text("No Videos in this Folder".localized(language))
                            .font(.custom("Urbanist-Bold", size: 20))
                            .foregroundColor(.white)
                        
                        Text("Download videos and save them to this folder".localized(language))
                            .font(.custom("Urbanist-Medium", size: 16))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    Spacer()
                }
                
                // MARK: - GRID
                else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            
                            if folder.isDeviceVideos {
                                ForEach(deviceVideos) { deviceVideo in
                                    DeviceVideoCardView(video: deviceVideo) {
                                        selectedDeviceVideo = deviceVideo
                                        showDeviceVideoView = true
                                    }
                                }
                            } else {
                                ForEach(videos) { video in
                                    SavedVideoCardView(
                                        video: video,
                                        showDeleteButton: true
                                    ) {
                                        videoToDelete = video
                                        showDeleteVideoAlert = true
                                    }
                                    .onTapGesture {
                                        selectedVideo = video
                                        showFullVideoView = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                    .refreshable {
                        if folder.isDeviceVideos {
                            await refreshDeviceVideosAsync()
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        
        // MARK: - Navigation
        .navigationDestination(isPresented: $showFullVideoView) {
            if let video = selectedVideo {
                FullVideoView(video: video)
            }
        }
        
        .sheet(isPresented: $showDeviceVideoView) {
            if let deviceVideo = selectedDeviceVideo {
                DeviceVideoPlayerView(video: deviceVideo)
            }
        }
        
        .alert("Delete Video".localized(language), isPresented: $showDeleteVideoAlert) {
            Button("Cancel".localized(language), role: .cancel) {
                videoToDelete = nil
            }
            Button("Delete".localized(language), role: .destructive) {
                if let video = videoToDelete {
                    deleteVideo(video)
                }
            }
        } message: {
            if let video = videoToDelete {
                let videoName = video.musicName ?? "this video".localized(language)
                Text("\("Are you sure you want to delete".localized(language)) \"\(videoName)\"?")
            } else {
                Text("Are you sure you want to delete this video?".localized(language))
            }
        }
        
        .onAppear {
            loadContent()
        }
        
        .onDisappear {
            cancelLoadTask()
        }
    }
    
    // MARK: - Logic
    private func loadContent() {
        if folder.isDeviceVideos {
            folderManager.quickLoadDeviceVideos()
            deviceVideos = folderManager.deviceVideos
            
            if deviceVideos.isEmpty {
                folderManager.loadDeviceVideos(forceRefresh: true) {
                    DispatchQueue.main.async {
                        deviceVideos = folderManager.deviceVideos
                    }
                }
            } else {
                folderManager.loadDeviceVideos(forceRefresh: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    deviceVideos = folderManager.deviceVideos
                }
            }
        } else {
            videos = folderManager.getVideosForFolder(folderId: folder.id)
        }
    }
    
    private func refreshDeviceVideos() {
        isLoading = true
        folderManager.loadDeviceVideos(forceRefresh: true) {
            DispatchQueue.main.async {
                deviceVideos = folderManager.deviceVideos
                isLoading = false
            }
        }
    }
    
    private func refreshDeviceVideosAsync() async {
        await withCheckedContinuation { continuation in
            folderManager.loadDeviceVideos(forceRefresh: true) {
                DispatchQueue.main.async {
                    deviceVideos = folderManager.deviceVideos
                    continuation.resume()
                }
            }
        }
    }
    
    private func cancelLoadTask() {
        loadTask?.cancel()
        loadTask = nil
    }
    
    private func deleteVideo(_ video: SavedVideo) {
        if let index = folderManager.folders.firstIndex(where: { $0.id == folder.id }) {
            folderManager.folders[index].videoIds.removeAll { $0 == video.id }
            folderManager.saveFolders()
        }
        
        SavedVideosManager.shared.deleteVideo(video)
        loadContent()
        videoToDelete = nil
    }
}


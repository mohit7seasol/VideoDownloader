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
                        Image("app_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: isIpad ? 140 : 120,
                                height: isIpad ? 42 : 32
                            )
                        
                        Spacer()
                        
                        // Create Folder Button - Only show when folders exist
                        if !folderManager.folders.isEmpty {
                            Button(action: {
                                showRenameFolderAlert = true
                                newFolderName = ""
                                folderToRename = nil
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .medium))
                                    .frame(width: 44, height: 44) // Increased tap area
                                    .contentShape(Rectangle())
                            }
                        } else {
                            // Empty view for balance when no folders
                            Color.clear
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.horizontal, 24)
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
                        }
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
                Text("Are you sure you want to delete folder \"\(folder.name)\"? Videos inside will not be deleted.")
                    .font(.custom("Urbanist-Medium", size: 16))
            } else {
                Text("Are you sure you want to delete this folder?")
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
        }
    }
}

// MARK: - Folder Content View
struct FolderContentView: View {
    let folder: VideoFolder
    @StateObject private var folderManager = FolderManager.shared
    @State private var videos: [SavedVideo] = []
    @State private var selectedVideo: SavedVideo?
    @State private var showFullVideoView = false
    @Environment(\.dismiss) var dismiss
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    private let columns: [GridItem] = {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let count = isIPad ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
    }()
    
    var body: some View {
        ZStack {
            Image("app_bg_image")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
            VStack {
                // Custom header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back".localized(language))
                        }
                        .foregroundColor(.white)
                        .frame(height: 44)
                        .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    Text(folder.name)
                        .font(.custom("Urbanist-Bold", size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty view for balance
                    Color.clear.frame(width: 60, height: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first?.windows
                    .first?.safeAreaInsets.top ?? 0)
                
                if videos.isEmpty {
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
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(videos) { video in
                                SavedVideoCardView(video: video) {
                                    // Delete video from folder
                                    if let index = folderManager.folders.firstIndex(where: { $0.id == folder.id }) {
                                        folderManager.folders[index].videoIds.removeAll { $0 == video.id }
                                        folderManager.saveFolders()
                                        loadVideos()
                                        
                                        // Also delete from SavedVideosManager if needed
                                        SavedVideosManager.shared.deleteVideo(video)
                                    }
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
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showFullVideoView) {
            if let video = selectedVideo {
                FullVideoView(video: video)
            }
        }
        .onAppear {
            loadVideos()
        }
    }
    
    private func loadVideos() {
        videos = folderManager.getVideosForFolder(folderId: folder.id)
    }
}

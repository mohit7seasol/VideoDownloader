//
//  FolderSelectionView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 19/03/26.
//

import SwiftUI

struct FolderSelectionView: View {
    @ObservedObject var folderManager: FolderManager
    var onFolderSelected: (VideoFolder) -> Void
    var onCreateNewFolder: () -> Void
    @Environment(\.dismiss) var dismiss
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "#0A0F1E").ignoresSafeArea()
                
                VStack {
                    if folderManager.folders.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("No Folders Yet".localized(language))
                                .font(.custom("Urbanist-Bold", size: 20))
                                .foregroundColor(.white)
                            
                            Text("Create a folder to organize your videos".localized(language))
                                .font(.custom("Urbanist-Medium", size: 16))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                            
                            Button(action: onCreateNewFolder) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create New Folder".localized(language))
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
                        .padding(.horizontal, 40)
                    } else {
                        // Folders Grid
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(folderManager.folders) { folder in
                                    FolderSelectionCard(
                                        folder: folder,
                                        videoCount: folderManager.getVideosForFolder(folderId: folder.id).count
                                    ) {
                                        onFolderSelected(folder)
                                        dismiss()
                                    }
                                }
                                
                                // Create New Folder Card
                                Button(action: onCreateNewFolder) {
                                    VStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                )
                                            
                                            Image(systemName: "plus")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        .frame(height: 120)
                                        
                                        Text("New Folder".localized(language))
                                            .font(.custom("Urbanist-Medium", size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                            .lineLimit(1)
                                    }
                                    .padding(8)
                                }
                            }
                            .padding(16)
                        }
                    }
                }
            }
            .navigationTitle("Select Folder".localized(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel".localized(language)) {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct FolderSelectionCard: View {
    let folder: VideoFolder
    let videoCount: Int
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#1973E8").opacity(0.2),
                                Color(hex: "#0E4082").opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                Image("folder_ic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)
            }
            .frame(height: 120)
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        if videoCount > 0 {
                            Text("\(videoCount)")
                                .font(.custom("Urbanist-Bold", size: 12))
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color(hex: "#1973E8"))
                                .clipShape(Circle())
                                .padding(8)
                        }
                    }
                    Spacer()
                }
            )
            
            Text(folder.name)
                .font(.custom("Urbanist-Medium", size: 14))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .onTapGesture(perform: onSelect)
    }
}

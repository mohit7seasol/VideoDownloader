//
//  FolderViewCard.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 19/03/26.
//

import SwiftUI

struct FolderViewCard: View {
    let folder: VideoFolder
    let videoCount: Int
    var onTap: () -> Void
    var onDelete: () -> Void
    var onRename: () -> Void
    
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        VStack(spacing: 8) {
            // Folder Icon
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
                // Video count badge
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
            
            // Folder Name
            Text(folder.name)
                .font(.custom("Urbanist-Medium", size: 14))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
            
            // Context Menu Button (3 dots)
            Menu {
                Button(action: onRename) {
                    Label("Rename".localized(language), systemImage: "pencil")
                }
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete".localized(language), systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .onTapGesture {
            onTap()
        }
    }
}

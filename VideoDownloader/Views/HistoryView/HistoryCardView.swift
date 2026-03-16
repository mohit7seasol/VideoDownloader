//
//  HistoryCardView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 16/03/26.
//

import SwiftUI

struct HistoryCardView: View {
    let video: SavedVideo
    let onDelete: () -> Void
    
    @State private var thumbnailImage: UIImage?
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Thumbnail
            if let thumbnail = thumbnailImage {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                // Placeholder
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1973E8").opacity(0.3), Color(hex: "0E4082").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "video.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
            
            // Music indicator if music was used
            if video.musicName != nil {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "music.note")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color(hex: "1973E8"))
                            .clipShape(Circle())
                            .padding(8)
                    }
                    Spacer()
                }
            }
            
            // Delete button
            Button(action: onDelete) {
                Image("delete_ic")
                    .resizable()
                    .frame(width: isIPad ? 32 : 22, height: isIPad ? 32 : 22)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(8)
        }
        .frame(height: 180)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        if let thumbnailURL = video.thumbnailURL,
           let data = try? Data(contentsOf: thumbnailURL),
           let image = UIImage(data: data) {
            thumbnailImage = image
        }
    }
}

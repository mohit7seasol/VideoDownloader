//
//  DeviceVideoCardView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 20/03/26.
//

import SwiftUI
import AVFoundation

struct DeviceVideoCardView: View {
    let video: DeviceVideo
    let onTap: () -> Void
    
    @State private var thumbnailImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        if Device.isIpad {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    // MARK: - Thumbnail Container (Square)
                    ZStack {
                        GeometryReader { thumbnailGeo in
                            let size = thumbnailGeo.size
                            
                            Group {
                                if let image = thumbnailImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size.width, height: size.height)
                                        .clipped()
                                } else if isLoading {
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "#471428"),
                                            Color(hex: "#111637")
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .overlay(
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(1.2)
                                    )
                                } else {
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "#471428"),
                                            Color(hex: "#111637")
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .overlay(
                                        Image(systemName: "play.circle")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.6))
                                    )
                                }
                            }
                        }
                        
                        // Gradient Overlay
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.black.opacity(0.6)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        // Duration Badge
                        VStack {
                            HStack {
                                Spacer()
                                Text(video.formattedDuration)
                                    .font(.custom("Urbanist-Medium", size: 12))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(6)
                                    .padding(10)
                            }
                            Spacer()
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // MARK: - Date Info
                    HStack {
                        Text(formatDate(video.creationDate))
                            .font(.custom("Urbanist-Medium", size: 13))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#471428").opacity(0.9),
                                Color(hex: "#111637").opacity(0.9)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .cornerRadius(16)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                )
                .onAppear {
                    loadThumbnail()
                }
                .onTapGesture {
                    onTap()
                }
            }
            .frame(height: 450) // Fixed height for iPad cards
        } else {
            VStack(spacing: 0) {
                
                // MARK: - Thumbnail Container (Square)
                ZStack {
                    GeometryReader { geo in
                        let size = geo.size
                        
                        Group {
                            if let image = thumbnailImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.width, height: size.height) // ✅ force fit
                                    .clipped() // ✅ VERY IMPORTANT
                            } else if isLoading {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#471428"),
                                        Color(hex: "#111637")
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .overlay(
                                    ProgressView()
                                        .tint(.white)
                                )
                            } else {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#471428"),
                                        Color(hex: "#111637")
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .overlay(
                                    Image(systemName: "play.circle")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white.opacity(0.6))
                                )
                            }
                        }
                    }
                    
                    // Gradient Overlay
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Duration Badge
                    VStack {
                        HStack {
                            Spacer()
                            Text(video.formattedDuration)
                                .font(.custom("Urbanist-Medium", size: 10))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(4)
                                .padding(8)
                        }
                        Spacer()
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12)) // ✅ prevents overflow
                
                // MARK: - Date Info
                HStack {
                    Text(formatDate(video.creationDate))
                        .font(.custom("Urbanist-Medium", size: 11))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#471428").opacity(0.9),
                            Color(hex: "#111637").opacity(0.9)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .cornerRadius(12)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
            .onAppear {
                loadThumbnail()
            }
            .onTapGesture {
                onTap()
            }
        }
    }
    
    // MARK: - Load Thumbnail
    private func loadThumbnail() {
        guard thumbnailImage == nil else { return }
        
        if let thumbnail = video.thumbnail {
            thumbnailImage = thumbnail
            return
        }
        
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: video.videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: Device.isIpad ? 300 : 300, height: Device.isIpad ? 450 : 300)
            
            do {
                let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                
                DispatchQueue.main.async {
                    thumbnailImage = thumbnail
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
    }
    
    // MARK: - Date Format
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

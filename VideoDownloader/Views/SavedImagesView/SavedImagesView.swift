//
//  SavedImagesView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 17/04/26.
//

import SwiftUI

struct SavedImagesView: View {
    @State private var savedImages: [UIImage] = []
    @State private var showDeleteAlert = false
    @State private var imageToDelete: Int?
    @State private var animateGradient = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]
    
    var body: some View {
        ZStack {
            Image("app_bg_image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if savedImages.isEmpty {
                // Attractive Empty State View
                VStack(spacing: 25) {
                    // Animated icon container
                    ZStack {
                        // Outer glowing circle
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
                            .animation(
                                Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                value: animateGradient
                            )
                        
                        // Inner circle
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        // Icon
                        Image(systemName: "photo.stack")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.3), radius: 10)
                    }
                    .padding(.top, 60)
                    
                    // Main title with gradient
                    Text("No Saved Images")
                        .font(.custom("Urbanist-Bold", size: 24))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Subtitle
                    Text("Your saved images will appear here")
                        .font(.custom("Urbanist-Medium", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    // Divider with gradient
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
                    
                    // Informational message with icon
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#3F5EFB"))
                        
                        Text("Images saved from editor will appear in this gallery")
                            .font(.custom("Urbanist-Regular", size: 13))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    
                    // Decorative elements
                    HStack(spacing: 20) {
                        ForEach(0..<3) { _ in
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.top, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    // Subtle radial gradient background
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(Array(savedImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: (UIScreen.main.bounds.width - 32) / 3, height: (UIScreen.main.bounds.width - 32) / 3)
                                    .clipped()
                                    .aspectRatio(1, contentMode: .fill)
                                    .overlay(
                                        // Subtle overlay on tap
                                        Rectangle()
                                            .fill(Color.black.opacity(0.0))
                                    )
                                
                                // Delete button on top right
                                Button(action: {
                                    imageToDelete = index
                                    showDeleteAlert = true
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.3), radius: 2)
                                }
                                .padding(8)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.top, UIApplication.shared.safeAreaTop + 10)
            }
        }
        .onAppear {
            loadSavedImages()
            animateGradient = true
        }
        .alert("Delete Image", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let index = imageToDelete {
                    deleteImage(at: index)
                }
            }
        } message: {
            Text("Are you sure you want to delete this image?")
        }
    }
    
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
}

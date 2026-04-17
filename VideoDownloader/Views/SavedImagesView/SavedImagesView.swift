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
    
    var body: some View {
        if Device.isIpad {
            GeometryReader { geometry in
                ZStack {
                    Image("app_bg_image")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    if savedImages.isEmpty {
                        // Attractive Empty State View - Vertically Centered for iPad
                        ScrollView {
                            VStack(spacing: 25) {
                                Spacer(minLength: 0)
                                
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
                                        .frame(width: 160, height: 160)
                                        .scaleEffect(animateGradient ? 1.1 : 1.0)
                                        .animation(
                                            Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                            value: animateGradient
                                        )
                                    
                                    // Inner circle
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 140, height: 140)
                                    
                                    // Icon
                                    Image(systemName: "photo.stack")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white)
                                        .shadow(color: .white.opacity(0.3), radius: 10)
                                }
                                
                                // Main title with gradient
                                Text("No Saved Images")
                                    .font(.custom("Urbanist-Bold", size: 34))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                // Subtitle
                                Text("Your saved images will appear here")
                                    .font(.custom("Urbanist-Medium", size: 18))
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                
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
                                    .frame(width: 250, height: 1)
                                    .padding(.vertical, 10)
                                
                                // Informational message
                                Text("Start editing photos and save them to see them here")
                                    .font(.custom("Urbanist-Regular", size: 16))
                                    .foregroundColor(.white.opacity(0.5))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 50)
                                
                                Spacer(minLength: 0)
                            }
                            .frame(minHeight: geometry.size.height)
                            .padding(.horizontal, 20)
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: gridSpacing) {
                                ForEach(Array(savedImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        // Image with corner radius and equal size
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
                                        
                                        // Trash button on top right
                                        Button(action: {
                                            imageToDelete = index
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
                        .padding(.top, UIApplication.shared.safeAreaTop + 10)
                        .padding(.bottom, Device.bottomSafeArea + 70)
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
        } else {
            // iPhone Layout
            ZStack {
                Image("app_bg_image")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                if savedImages.isEmpty {
                    // Attractive Empty State View for iPhone
                    ScrollView {
                        VStack(spacing: 25) {
                            Spacer(minLength: 0)
                            
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
                                .padding(.horizontal, 20)
                            
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
                            
                            Spacer(minLength: 0)
                        }
                        .frame(minHeight: UIScreen.main.bounds.height - 100)
                        .padding(.horizontal, 20)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: gridSpacing) {
                            ForEach(Array(savedImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    // Image with corner radius and equal size
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
                                    
                                    // Trash button on top right
                                    Button(action: {
                                        imageToDelete = index
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
                    .padding(.top, UIApplication.shared.safeAreaTop + 10)
                    .padding(.bottom, Device.bottomSafeArea + 70)
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

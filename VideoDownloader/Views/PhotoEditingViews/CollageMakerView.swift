//
//  CollageMakerView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 16/04/26.
//

import SwiftUI
import PhotosUI

struct CollageMakerView: View {
    var selectedImages: [UIImage] = []
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedGrid: GridType = .single
    @State private var photos: [CollagePhotoItem] = []
    @State private var selectedPhotoIndex: Int?
    @State private var showPhotoPicker = false
    @State private var isEditing = false
    @State private var selectedPickerItem: PhotosPickerItem?
    
    let collageSize: CGSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 500)
    
    // Pre-computed grid items to avoid compiler type-check issues
    private let gridItems: [GridType] = GridType.allCases
    
    init(selectedImages: [UIImage] = []) {
        self.selectedImages = selectedImages
    }
    
    var body: some View {
        ZStack {
            // App Background Image
            Image("app_bg_image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    
                    Spacer()
                    
                    Text("Collage Maker")
                        .font(.custom("Urbanist-Bold", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveCollage()
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal, 20)
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                .padding(.bottom, 16)
                
                // Collage View
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: collageSize.width, height: collageSize.height)
                    
                    ZStack {
                        ForEach(photos.indices, id: \.self) { index in
                            let photo = photos[index]
                            
                            if photo.isPlaceholder {
                                // Placeholder with Plus Icon
                                Rectangle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: photo.frame.width * collageSize.width,
                                           height: photo.frame.height * collageSize.height)
                                    .position(x: (photo.frame.midX) * collageSize.width,
                                              y: (photo.frame.midY) * collageSize.height)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "plus")
                                                .foregroundColor(.white.opacity(0.6))
                                                .font(.system(size: 36, weight: .thin))
                                            Text("Add Photo")
                                                .foregroundColor(.white.opacity(0.5))
                                                .font(.system(size: 12))
                                        }
                                    )
                                    .onTapGesture {
                                        selectedPhotoIndex = index
                                        showPhotoPicker = true
                                    }
                            } else if let image = photo.image {
                                // Actual Image
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: photo.frame.width * collageSize.width,
                                           height: photo.frame.height * collageSize.height)
                                    .clipped()
                                    .overlay(
                                        Rectangle()
                                            .stroke(selectedPhotoIndex == index ? Color.blue : Color.clear, lineWidth: 3)
                                    )
                                    .position(x: (photo.frame.midX) * collageSize.width,
                                              y: (photo.frame.midY) * collageSize.height)
                                    .onTapGesture {
                                        if isEditing {
                                            selectedPhotoIndex = index
                                            showPhotoPicker = true
                                        }
                                    }
                            }
                        }
                    }
                    .frame(width: collageSize.width, height: collageSize.height)
                    .clipped()
                }
                .padding(.horizontal, 20)
                
                // Edit Mode Toggle
                HStack {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                                .font(.system(size: 18))
                            Text(isEditing ? "Done Editing" : "Edit Photos")
                                .font(.custom("Urbanist-Medium", size: 14))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#A925CA").opacity(0.3))
                        .cornerRadius(25)
                    }
                    
                    Spacer()
                    
                    if isEditing && selectedPhotoIndex != nil {
                        Button(action: {
                            if let index = selectedPhotoIndex {
                                photos[index].isPlaceholder = true
                                photos[index].image = nil
                                selectedPhotoIndex = nil
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                    .font(.system(size: 16))
                                Text("Remove")
                                    .font(.custom("Urbanist-Medium", size: 14))
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.25))
                            .cornerRadius(25)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                Spacer(minLength: 0)
                
                // Grid Selection - Bottom Scroll
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 0.5)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(gridItems, id: \.self) { grid in
                                GridButton(
                                    grid: grid,
                                    isSelected: selectedGrid == grid,
                                    action: {
                                        selectedGrid = grid
                                        updateGridLayout()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    .background(Color.black.opacity(0.3))
                }
                .padding(.bottom, 0)
            }
        }
        .navigationBarHidden(true)
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPickerItem, matching: .images)
        .onChange(of: selectedPickerItem) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        if let index = selectedPhotoIndex {
                            photos[index].image = image
                            photos[index].isPlaceholder = false
                            selectedPhotoIndex = nil
                        }
                        selectedPickerItem = nil
                    }
                }
            }
        }
        .onAppear {
            updateGridLayout()
            if !selectedImages.isEmpty {
                for (index, image) in selectedImages.enumerated() {
                    if index < photos.count {
                        photos[index].image = image
                        photos[index].isPlaceholder = false
                    }
                }
            }
        }
    }
    
    private func updateGridLayout() {
        let layouts = selectedGrid.layout
        var newPhotos: [CollagePhotoItem] = []
        
        for layout in layouts {
            newPhotos.append(CollagePhotoItem(
                image: nil,
                isPlaceholder: true,
                frame: layout
            ))
        }
        
        if photos.count == newPhotos.count {
            for i in 0..<newPhotos.count {
                if i < photos.count {
                    newPhotos[i].image = photos[i].image
                    newPhotos[i].isPlaceholder = photos[i].isPlaceholder
                }
            }
        }
        
        photos = newPhotos
    }
    
    private func saveCollage() {
        let renderer = UIGraphicsImageRenderer(size: collageSize)
        let finalImage = renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: collageSize))
            
            for photo in photos {
                let rect = CGRect(
                    x: photo.frame.minX * collageSize.width,
                    y: photo.frame.minY * collageSize.height,
                    width: photo.frame.width * collageSize.width,
                    height: photo.frame.height * collageSize.height
                )
                
                if let image = photo.image {
                    image.draw(in: rect)
                }
            }
        }
        
        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
        dismiss()
    }
}
struct GridButton: View {
    let grid: GridType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: grid.icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Color(hex: "#A925CA") : .white.opacity(0.6))
                    .frame(width: 44, height: 44)
                    .background(isSelected ? Color(hex: "#A925CA").opacity(0.2) : Color.clear)
                    .cornerRadius(12)
                
                Text(grid.displayName)
                    .font(.custom("Urbanist-Medium", size: 11))
                    .foregroundColor(isSelected ? Color(hex: "#A925CA") : .white.opacity(0.5))
            }
        }
    }
}

// MARK: - CollageGridSelectorView
struct CollageGridSelectorView: View {
    @State private var selectedGrid: GridType = .single
    @State private var selectedImages: [UIImage?] = []
    @State private var showImagePicker = false
    @State private var currentPickerIndex = 0
    @State private var selectedPickerItem: PhotosPickerItem?
    
    private let gridItems: [GridType] = GridType.allCases
    
    var body: some View {
        ZStack {
            Image("app_bg_image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") { }
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Collage Maker")
                        .font(.custom("Urbanist-Bold", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveCollage()
                    }
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.top, Device.topSafeArea)
                .padding(.bottom, Device.bottomSafeArea)
                
                CollagePreview(
                    gridType: selectedGrid,
                    images: selectedImages,
                    onTapImage: { index in
                        currentPickerIndex = index
                        showImagePicker = true
                    }
                )
                .frame(height: 450)
                .padding(.horizontal, 20)
                
                Spacer()
                
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 0.5)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(gridItems, id: \.self) { grid in
                                GridButton(
                                    grid: grid,
                                    isSelected: selectedGrid == grid,
                                    action: {
                                        selectedGrid = grid
                                        selectedImages = Array(repeating: nil, count: grid.layout.count)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    .background(Color.black.opacity(0.3))
                }
                .padding(.bottom, 40) 
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedPickerItem, matching: .images)
        .onChange(of: selectedPickerItem) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        selectedImages[currentPickerIndex] = image
                        selectedPickerItem = nil
                    }
                }
            }
        }
    }
    
    private func saveCollage() {
        let collageSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 500)
        let renderer = UIGraphicsImageRenderer(size: collageSize)
        let layouts = selectedGrid.layout
        
        let finalImage = renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: collageSize))
            
            for (index, layout) in layouts.enumerated() {
                if index < selectedImages.count, let image = selectedImages[index] {
                    let rect = CGRect(
                        x: layout.minX * collageSize.width,
                        y: layout.minY * collageSize.height,
                        width: layout.width * collageSize.width,
                        height: layout.height * collageSize.height
                    )
                    image.draw(in: rect)
                }
            }
        }
        
        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
    }
}
// MARK: - CollagePreview
struct CollagePreview: View {
    let gridType: GridType
    let images: [UIImage?]
    let onTapImage: (Int) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let layouts = gridType.layout
            ZStack {
                ForEach(0..<min(layouts.count, images.count), id: \.self) { index in
                    let layout = layouts[index]
                    let rect = CGRect(
                        x: layout.minX * geometry.size.width,
                        y: layout.minY * geometry.size.height,
                        width: layout.width * geometry.size.width,
                        height: layout.height * geometry.size.height
                    )
                    
                    Button(action: {
                        onTapImage(index)
                    }) {
                        if let image = images[index] {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: rect.width, height: rect.height)
                                .clipped()
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                }
            }
        }
    }
}


// MARK: - Preview
#Preview {
    CollageMakerView()
}

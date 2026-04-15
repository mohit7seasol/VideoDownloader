//
//  StickerEditorView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 15/04/26.
//

import SwiftUI
import Photos

struct StickerEditorView: View {
    let originalImage: UIImage
    let onImageEdited: (UIImage) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var baseImage: UIImage
    @State private var stickers: [SimpleSticker] = []
    @State private var selectedStickerIndex: Int?
    @State private var imageFrame: CGRect = .zero
    @State private var imageSize: CGSize = .zero
    
    let stickerImages = ["s1", "s2", "s3", "s4"]
    
    init(image: UIImage, onImageEdited: @escaping (UIImage) -> Void) {
        self.originalImage = image
        self.onImageEdited = onImageEdited
        _baseImage = State(initialValue: image)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Add Stickers")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Done") {
                        saveImage()
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                
                // Main Image View with Stickers
                GeometryReader { geometry in
                    ZStack {
                        // Base Image
                        Image(uiImage: baseImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(20)
                            .padding(.horizontal, 15)
                            .padding(.top, 20)
                            .overlay(
                                GeometryReader { imgGeometry in
                                    Color.clear
                                        .onAppear {
                                            let frame = imgGeometry.frame(in: .global)
                                            imageFrame = frame
                                            imageSize = frame.size
                                        }
                                        .onChange(of: imgGeometry.frame(in: .global)) { newFrame in
                                            imageFrame = newFrame
                                            imageSize = newFrame.size
                                        }
                                }
                            )
                        
                        // Stickers Overlay
                        ForEach(stickers.indices, id: \.self) { index in
                            SimpleStickerView(
                                sticker: stickers[index],
                                isSelected: selectedStickerIndex == index,
                                imageFrame: imageFrame,
                                imageSize: imageSize,
                                onTap: {
                                    selectedStickerIndex = index
                                },
                                onDrag: { newPosition in
                                    stickers[index].position = newPosition
                                },
                                onZoom: { newScale in
                                    stickers[index].scale = newScale
                                },
                                onDelete: {
                                    stickers.remove(at: index)
                                    selectedStickerIndex = nil
                                }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Sticker Gallery
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(stickerImages, id: \.self) { stickerName in
                            if let stickerImage = UIImage(named: stickerName) {
                                Button {
                                    addSticker(image: stickerImage)
                                } label: {
                                    Image(uiImage: stickerImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 100)
                .padding(.vertical, 20)
                .background(Color.black.opacity(0.5))
            }
        }
        .onTapGesture {
            selectedStickerIndex = nil
        }
    }
    
    private func addSticker(image: UIImage) {
        // Calculate center position relative to image frame
        let centerX = imageFrame.midX
        let centerY = imageFrame.midY
        
        let newSticker = SimpleSticker(
            image: image,
            position: CGPoint(x: centerX, y: centerY),
            scale: 1.0
        )
        stickers.append(newSticker)
        selectedStickerIndex = stickers.count - 1
    }
    
    private func saveImage() {
        let renderer = UIGraphicsImageRenderer(size: baseImage.size)
        let finalImage = renderer.image { context in
            // Draw base image
            baseImage.draw(in: CGRect(origin: .zero, size: baseImage.size))
            
            // Calculate scale factor between displayed image and actual image
            let displaySize = imageSize
            let actualSize = baseImage.size
            let scaleX = actualSize.width / displaySize.width
            let scaleY = actualSize.height / displaySize.height
            
            // Draw all stickers with correct positioning
            for sticker in stickers {
                // Convert sticker position from display coordinates to actual image coordinates
                let relativeX = (sticker.position.x - imageFrame.minX) / displaySize.width
                let relativeY = (sticker.position.y - imageFrame.minY) / displaySize.height
                
                let actualX = relativeX * actualSize.width
                let actualY = relativeY * actualSize.height
                
                let stickerSize = CGSize(
                    width: actualSize.width * 0.2 * sticker.scale,
                    height: actualSize.width * 0.2 * sticker.scale
                )
                
                let stickerRect = CGRect(
                    x: actualX - stickerSize.width / 2,
                    y: actualY - stickerSize.height / 2,
                    width: stickerSize.width,
                    height: stickerSize.height
                )
                
                sticker.image.draw(in: stickerRect)
            }
        }
        
        onImageEdited(finalImage)
        dismiss()
    }
}

// MARK: - Simple Sticker Model
struct SimpleSticker: Identifiable {
    let id = UUID()
    let image: UIImage
    var position: CGPoint
    var scale: CGFloat
}

// MARK: - Simple Sticker View with Fixed Close Icon Position
struct SimpleStickerView: View {
    let sticker: SimpleSticker
    let isSelected: Bool
    let imageFrame: CGRect
    let imageSize: CGSize
    let onTap: () -> Void
    let onDrag: (CGPoint) -> Void
    let onZoom: (CGFloat) -> Void
    let onDelete: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var stickerSize: CGFloat = 100
    
    var body: some View {
        let currentStickerSize = stickerSize * sticker.scale * currentScale
        let stickerHalfSize = currentStickerSize / 2
        
        ZStack {
            // Sticker Image
            Image(uiImage: sticker.image)
                .resizable()
                .scaledToFit()
                .frame(width: currentStickerSize, height: currentStickerSize)
            
            // Delete Button (only when selected)
            if isSelected {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            onDelete()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Color.red)
                                .clipShape(Circle())
                                .font(.system(size: 24))
                        }
                        .offset(x: 12, y: -12)
                        Spacer()
                    }
                    Spacer()
                }
                .frame(width: currentStickerSize, height: currentStickerSize)
            }
        }
        .position(x: sticker.position.x + dragOffset.width,
                 y: sticker.position.y + dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if isSelected {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    if isSelected {
                        var newX = sticker.position.x + value.translation.width
                        var newY = sticker.position.y + value.translation.height
                        
                        // Constrain to image bounds
                        let minX = imageFrame.minX + stickerHalfSize
                        let maxX = imageFrame.maxX - stickerHalfSize
                        let minY = imageFrame.minY + stickerHalfSize
                        let maxY = imageFrame.maxY - stickerHalfSize
                        
                        newX = min(max(newX, minX), maxX)
                        newY = min(max(newY, minY), maxY)
                        
                        onDrag(CGPoint(x: newX, y: newY))
                        dragOffset = .zero
                    }
                }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    if isSelected {
                        currentScale = value
                    }
                }
                .onEnded { value in
                    if isSelected {
                        let newScale = sticker.scale * value
                        onZoom(max(0.3, min(3.0, newScale)))
                        currentScale = 1.0
                    }
                }
        )
        .onTapGesture {
            onTap()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
    }
}

// MARK: - Alternative Version with Better Close Button Positioning
struct ImprovedStickerEditorView: View {
    let originalImage: UIImage
    let onImageEdited: (UIImage) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var baseImage: UIImage
    @State private var stickers: [ImprovedSticker] = []
    @State private var selectedStickerId: UUID?
    @State private var imageFrame: CGRect = .zero
    @State private var imageSize: CGSize = .zero
    
    let stickerImages = ["s1", "s2", "s3", "s4"]
    
    init(image: UIImage, onImageEdited: @escaping (UIImage) -> Void) {
        self.originalImage = image
        self.onImageEdited = onImageEdited
        _baseImage = State(initialValue: image)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                    Spacer()
                    Text("Add Stickers").font(.headline).foregroundColor(.white)
                    Spacer()
                    Button("Done") { saveImage() }
                        .foregroundColor(.blue)
                }
                .padding()
                
                GeometryReader { geometry in
                    ZStack {
                        Image(uiImage: baseImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(20)
                            .padding(.horizontal, 15)
                            .padding(.top, 20)
                            .overlay(
                                GeometryReader { imgGeometry in
                                    Color.clear
                                        .onAppear {
                                            let frame = imgGeometry.frame(in: .global)
                                            imageFrame = frame
                                            imageSize = frame.size
                                        }
                                }
                            )
                        
                        ForEach($stickers) { $sticker in
                            ImprovedStickerView(
                                sticker: $sticker,
                                isSelected: selectedStickerId == sticker.id,
                                imageFrame: imageFrame,
                                imageSize: imageSize,
                                onTap: { selectedStickerId = sticker.id },
                                onDelete: {
                                    stickers.removeAll { $0.id == sticker.id }
                                    if selectedStickerId == sticker.id {
                                        selectedStickerId = nil
                                    }
                                }
                            )
                        }
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(stickerImages, id: \.self) { stickerName in
                            if let stickerImage = UIImage(named: stickerName) {
                                Button {
                                    addSticker(image: stickerImage)
                                } label: {
                                    Image(uiImage: stickerImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 100)
                .padding(.vertical, 20)
                .background(Color.black.opacity(0.5))
            }
        }
        .onTapGesture {
            selectedStickerId = nil
        }
    }
    
    private func addSticker(image: UIImage) {
        let newSticker = ImprovedSticker(
            image: image,
            position: CGPoint(x: imageFrame.midX, y: imageFrame.midY),
            scale: 1.0
        )
        stickers.append(newSticker)
        selectedStickerId = newSticker.id
    }
    
    private func saveImage() {
        let renderer = UIGraphicsImageRenderer(size: baseImage.size)
        let finalImage = renderer.image { context in
            baseImage.draw(in: CGRect(origin: .zero, size: baseImage.size))
            
            let scaleX = baseImage.size.width / imageSize.width
            let scaleY = baseImage.size.height / imageSize.height
            
            for sticker in stickers {
                let relativeX = (sticker.position.x - imageFrame.minX) / imageSize.width
                let relativeY = (sticker.position.y - imageFrame.minY) / imageSize.height
                
                let actualX = relativeX * baseImage.size.width
                let actualY = relativeY * baseImage.size.height
                
                let stickerSize = CGSize(
                    width: baseImage.size.width * 0.2 * sticker.scale,
                    height: baseImage.size.width * 0.2 * sticker.scale
                )
                
                let stickerRect = CGRect(
                    x: actualX - stickerSize.width / 2,
                    y: actualY - stickerSize.height / 2,
                    width: stickerSize.width,
                    height: stickerSize.height
                )
                
                sticker.image.draw(in: stickerRect)
            }
        }
        
        onImageEdited(finalImage)
        dismiss()
    }
}

struct ImprovedSticker: Identifiable {
    let id = UUID()
    let image: UIImage
    var position: CGPoint
    var scale: CGFloat
}

struct ImprovedStickerView: View {
    @Binding var sticker: ImprovedSticker
    let isSelected: Bool
    let imageFrame: CGRect
    let imageSize: CGSize
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    
    var body: some View {
        let stickerWidth: CGFloat = 100 * sticker.scale * currentScale
        let stickerHeight: CGFloat = 100 * sticker.scale * currentScale
        
        ZStack {
            Image(uiImage: sticker.image)
                .resizable()
                .scaledToFit()
                .frame(width: stickerWidth, height: stickerHeight)
            
            if isSelected {
                // Close button at top-right
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onDelete) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        .offset(x: 10, y: -10)
                        Spacer()
                    }
                    Spacer()
                }
                .frame(width: stickerWidth, height: stickerHeight)
                
                // Border
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: stickerWidth, height: stickerHeight)
            }
        }
        .position(x: sticker.position.x + dragOffset.width,
                 y: sticker.position.y + dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if isSelected {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    if isSelected {
                        var newX = sticker.position.x + value.translation.width
                        var newY = sticker.position.y + value.translation.height
                        
                        let halfSize = (100 * sticker.scale) / 2
                        newX = min(max(newX, imageFrame.minX + halfSize), imageFrame.maxX - halfSize)
                        newY = min(max(newY, imageFrame.minY + halfSize), imageFrame.maxY - halfSize)
                        
                        sticker.position = CGPoint(x: newX, y: newY)
                        dragOffset = .zero
                    }
                }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    if isSelected {
                        currentScale = value
                    }
                }
                .onEnded { value in
                    if isSelected {
                        let newScale = sticker.scale * value
                        sticker.scale = max(0.3, min(3.0, newScale))
                        currentScale = 1.0
                    }
                }
        )
        .onTapGesture {
            onTap()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
    }
}

// Use this as your main StickerEditorView
typealias FinalStickerEditorView = ImprovedStickerEditorView

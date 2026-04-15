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
                
                // HEADER
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Add Stickers")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("Done") {
                        saveImage()
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                
                // FULL SCREEN IMAGE
                GeometryReader { geo in
                    
                    ZStack {
                        
                        Image(uiImage: baseImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .background(
                                GeometryReader { imgGeo in
                                    Color.clear
                                        .onAppear {
                                            imageSize = imgGeo.size
                                        }
                                        .onChange(of: imgGeo.size) { newValue in
                                            imageSize = newValue
                                        }
                                }
                            )
                        
                        // STICKERS
                        ForEach(stickers.indices, id: \.self) { index in
                            
                            SimpleStickerView(
                                sticker: stickers[index],
                                isSelected: selectedStickerIndex == index,
                                onTap: {
                                    selectedStickerIndex = index
                                },
                                onDrag: { newPos in
                                    stickers[index].position = newPos
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
                }
                
                // STICKER LIST
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(stickerImages, id: \.self) { name in
                            if let img = UIImage(named: name) {
                                Button {
                                    addSticker(image: img)
                                } label: {
                                    Image(uiImage: img)
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
                .background(Color.black.opacity(0.6))
            }
        }
        .onTapGesture {
            selectedStickerIndex = nil
        }
    }
}

// MARK: - ADD STICKER
extension StickerEditorView {
    
    private func addSticker(image: UIImage) {
        
        let newSticker = SimpleSticker(
            image: image,
            position: CGPoint(
                x: imageSize.width / 2,
                y: imageSize.height / 2
            ),
            scale: 1.0
        )
        
        stickers.append(newSticker)
        selectedStickerIndex = stickers.count - 1
    }
}

// MARK: - SAVE IMAGE (🔥 FIXED)
extension StickerEditorView {
    
    private func saveImage() {
        
        let renderer = UIGraphicsImageRenderer(size: baseImage.size)
        
        let finalImage = renderer.image { ctx in
            
            baseImage.draw(in: CGRect(origin: .zero, size: baseImage.size))
            
            let displaySize = imageSize
            let actualSize = baseImage.size
            
            for sticker in stickers {
                
                // 🔥 PERFECT POSITION CONVERSION
                let relativeX = sticker.position.x / displaySize.width
                let relativeY = sticker.position.y / displaySize.height
                
                let actualX = relativeX * actualSize.width
                let actualY = relativeY * actualSize.height
                
                // 🔥 PERFECT SCALE (FIXED BUG)
                let baseStickerWidth: CGFloat = 100
                let displayScale = (actualSize.width / displaySize.width)
                
                let finalSize = baseStickerWidth * sticker.scale * displayScale
                
                let rect = CGRect(
                    x: actualX - finalSize / 2,
                    y: actualY - finalSize / 2,
                    width: finalSize,
                    height: finalSize
                )
                
                sticker.image.draw(in: rect)
            }
        }
        
        onImageEdited(finalImage)
        dismiss()
    }
}

// MARK: - MODEL
struct SimpleSticker: Identifiable {
    let id = UUID()
    let image: UIImage
    var position: CGPoint   // LOCAL to image
    var scale: CGFloat
}

// MARK: - STICKER VIEW
struct SimpleStickerView: View {
    
    let sticker: SimpleSticker
    let isSelected: Bool
    
    let onTap: () -> Void
    let onDrag: (CGPoint) -> Void
    let onZoom: (CGFloat) -> Void
    let onDelete: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var tempScale: CGFloat = 1.0
    
    var body: some View {
        
        let size: CGFloat = 100 * sticker.scale * tempScale
        
        ZStack {
            Image(uiImage: sticker.image)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
            
            if isSelected {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onDelete) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Color.red)
                                .clipShape(Circle())
                                .font(.system(size: 24))
                        }
                        .offset(x: 12, y: -12)
                    }
                    Spacer()
                }
                .frame(width: size, height: size)
            }
        }
        .position(
            x: sticker.position.x + dragOffset.width,
            y: sticker.position.y + dragOffset.height
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let newPos = CGPoint(
                        x: sticker.position.x + value.translation.width,
                        y: sticker.position.y + value.translation.height
                    )
                    onDrag(newPos)
                    dragOffset = .zero
                }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { val in
                    tempScale = val
                }
                .onEnded { val in
                    let newScale = sticker.scale * val
                    onZoom(max(0.3, min(4.0, newScale)))
                    tempScale = 1.0
                }
        )
        .onTapGesture {
            onTap()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
    }
}

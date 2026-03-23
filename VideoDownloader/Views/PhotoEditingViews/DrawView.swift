//
//  DrawView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 23/03/26.
//

import SwiftUI
import PencilKit

struct DrawView: View {
    
    let image: UIImage
    let onImageEdited: (UIImage) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var canvasView = PKCanvasView()
    @State private var selectedColor = Color.red
    @State private var selectedWidth: CGFloat = 5
    @State private var isDrawing = true
    @State private var imageViewSize = CGSize.zero
    
    // More colors
    let colors: [Color] = [
        .black, .white, .red, .orange, .yellow, .green, .blue, .purple,
        .pink, .brown, .cyan, .indigo, .mint, .teal
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    Text("Draw".localized(LocalizationService.shared.language))
                        .font(.custom("Poppins-Black", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        saveDrawing()
                    } label: {
                        Text("Save".localized(LocalizationService.shared.language))
                            .font(.custom("Urbanist-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 0)
                .padding(.bottom, 20)
                
                // Drawing Canvas
                GeometryReader { geometry in
                    let size = geometry.size
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: size.width, height: size.height)
                            .onAppear {
                                imageViewSize = size
                            }
                        
                        DrawingCanvas(canvasView: $canvasView, image: image, isDrawing: $isDrawing)
                            .frame(width: size.width, height: size.height)
                    }
                    .frame(width: size.width, height: size.height)
                }
                .padding(.horizontal, 15)
                .padding(.top, 15)
                .padding(.bottom, 15)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
                // Drawing Tools
                VStack(spacing: 20) {
                    // Color Picker with proper spacing and no clipping
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(colors, id: \.self) { color in
                                ColorCircleView(
                                    color: color,
                                    isSelected: selectedColor == color,
                                    size: 36
                                )
                                .onTapGesture {
                                    selectedColor = color
                                    updateTool()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                    .frame(height: 52)
                    
                    // Stroke Width Slider
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.white)
                        Slider(value: $selectedWidth, in: 1...20, step: 1)
                            .tint(.white)
                            .onChange(of: selectedWidth) { _ in
                                updateTool() // Update tool when width changes
                            }
                        Text("\(Int(selectedWidth))")
                            .foregroundColor(.white)
                            .font(.caption)
                            .frame(width: 30)
                    }
                    .padding(.horizontal, 40)
                    
                    // Clear Button
                    Button {
                        canvasView.drawing = PKDrawing()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                            Text("Clear All".localized(LocalizationService.shared.language))
                                .font(.custom("Urbanist-Medium", size: 14))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.red.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            setupCanvas()
        }
    }
    
    private func setupCanvas() {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        updateTool()
    }
    
    private func updateTool() {
        let color = UIColor(selectedColor)
        let tool = PKInkingTool(.pen, color: color, width: selectedWidth)
        canvasView.tool = tool
    }
    
    private func saveDrawing() {
        // Calculate scale factors between display size and actual image size
        let scaleX = image.size.width / imageViewSize.width
        let scaleY = image.size.height / imageViewSize.height
        
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let combinedImage = renderer.image { ctx in
            // Draw original image
            image.draw(in: CGRect(origin: .zero, size: image.size))
            
            // Get drawing image at actual image size
            let drawingImage = canvasView.drawing.image(from: CGRect(origin: .zero, size: imageViewSize), scale: 1.0)
            
            // Scale and position the drawing correctly
            drawingImage.draw(in: CGRect(origin: .zero, size: image.size))
        }
        
        onImageEdited(combinedImage)
        dismiss()
    }
}

// MARK: - ColorCircleView
struct ColorCircleView: View {
    let color: Color
    let isSelected: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Outer ring for selected state
            if isSelected {
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: size + 8, height: size + 8)
            }
            
            // Main color circle
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
        }
        .frame(width: size + (isSelected ? 12 : 0), height: size + (isSelected ? 12 : 0))
    }
}

// MARK: - DrawingCanvas
struct DrawingCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let image: UIImage
    @Binding var isDrawing: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update if needed
    }
}

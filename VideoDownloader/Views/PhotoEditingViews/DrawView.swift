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
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
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
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                // Drawing Canvas
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    
                    DrawingCanvas(canvasView: $canvasView, image: image, isDrawing: $isDrawing)
                        .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
                }
                .frame(height: UIScreen.main.bounds.width - 40)
                
                Spacer()
                
                // Drawing Tools
                VStack(spacing: 20) {
                    // Color Picker
                    HStack(spacing: 15) {
                        ForEach([Color.black, .white, .red, .yellow, .blue, .purple, .green, .orange], id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 35, height: 35)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                    updateTool()
                                }
                        }
                    }
                    
                    // Stroke Width Slider
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.white)
                        Slider(value: $selectedWidth, in: 1...20, step: 1)
                            .tint(.white)
                        Text("\(Int(selectedWidth))")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding(.horizontal, 40)
                    
                    // Clear Button
                    Button {
                        canvasView.drawing = PKDrawing()
                    } label: {
                        Text("Clear".localized(LocalizationService.shared.language))
                            .foregroundColor(.red)
                            .font(.custom("Urbanist-Medium", size: 14))
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
        // Combine image and drawing
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let combinedImage = renderer.image { ctx in
            image.draw(in: CGRect(origin: .zero, size: image.size))
            
            let drawingImage = canvasView.drawing.image(from: CGRect(origin: .zero, size: image.size), scale: 1.0)
            drawingImage.draw(in: CGRect(origin: .zero, size: image.size))
        }
        
        onImageEdited(combinedImage)
        dismiss()
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

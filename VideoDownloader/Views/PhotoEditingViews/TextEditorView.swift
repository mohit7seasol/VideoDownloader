//
//  TextEditorView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 23/03/26.
//

import SwiftUI

struct TextEditorView: View {
    
    let image: UIImage
    let onImageEdited: (UIImage) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var textItems: [TextItem] = []
    @State private var showAddText = false
    @State private var currentText = ""
    @State private var selectedFont = "Helvetica"
    @State private var selectedColor = Color.white
    @State private var fontSize: CGFloat = 24
    @State private var imageViewSize = CGSize.zero
    
    let fonts = ["Helvetica", "Arial", "Times New Roman", "Courier", "Georgia", "Verdana"]
    
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
                    }
                    
                    Spacer()
                    
                    Text("Add Text".localized(LocalizationService.shared.language))
                        .font(.custom("Poppins-Black", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        saveImage()
                    } label: {
                        Text("Save".localized(LocalizationService.shared.language))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                // Image with text overlay
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
                        
                        ForEach($textItems) { $item in
                            DraggableTextItem(
                                text: $item.text,
                                fontSize: item.fontSize,
                                color: item.color,
                                font: item.font,
                                position: $item.position,
                                scale: $item.scale,
                                rotation: $item.rotation,
                                viewSize: size
                            )
                        }
                    }
                    .frame(width: size.width, height: size.height)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showAddText = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
                // Add Text Button
                Button {
                    showAddText = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Text".localized(LocalizationService.shared.language))
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showAddText) {
            TextInputSheet(
                text: $currentText,
                fontSize: $fontSize,
                font: $selectedFont,
                color: $selectedColor,
                fonts: fonts
            ) {
                if !currentText.isEmpty {
                    let newItem = TextItem(
                        text: currentText,
                        fontSize: fontSize,
                        color: selectedColor,
                        font: selectedFont,
                        position: CGPoint(x: imageViewSize.width / 2, y: imageViewSize.height / 2),
                        scale: 1.0,
                        rotation: 0.0
                    )
                    textItems.append(newItem)
                    currentText = ""
                }
                showAddText = false
            }
        }
    }
    
    private func saveImage() {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let finalImage = renderer.image { ctx in
            // Draw original image
            image.draw(in: CGRect(origin: .zero, size: image.size))
            
            // Calculate scale factors between display size and actual image size
            let scaleX = image.size.width / imageViewSize.width
            let scaleY = image.size.height / imageViewSize.height
            
            // Draw all text items
            for item in textItems {
                let text = item.text
                let fontSizeScaled = item.fontSize * item.scale * min(scaleX, scaleY)
                let font = UIFont(name: item.font, size: fontSizeScaled) ?? .systemFont(ofSize: fontSizeScaled)
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor(item.color)
                ]
                
                let textSize = (text as NSString).size(withAttributes: attributes)
                
                // Convert position from display coordinates to image coordinates
                let positionInImage = CGPoint(
                    x: item.position.x * scaleX,
                    y: item.position.y * scaleY
                )
                
                // Apply rotation
                ctx.cgContext.saveGState()
                ctx.cgContext.translateBy(x: positionInImage.x, y: positionInImage.y)
                ctx.cgContext.rotate(by: CGFloat(item.rotation * .pi / 180))
                
                let textRect = CGRect(
                    x: -textSize.width / 2,
                    y: -textSize.height / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                
                (text as NSString).draw(in: textRect, withAttributes: attributes)
                ctx.cgContext.restoreGState()
            }
        }
        
        onImageEdited(finalImage)
        dismiss()
    }
}

// MARK: - TextItem Model
struct TextItem: Identifiable {
    let id = UUID()
    var text: String
    var fontSize: CGFloat
    var color: Color
    var font: String
    var position: CGPoint
    var scale: CGFloat
    var rotation: Double
}

// MARK: - DraggableTextItem
struct DraggableTextItem: View {
    @Binding var text: String
    let fontSize: CGFloat
    let color: Color
    let font: String
    @Binding var position: CGPoint
    @Binding var scale: CGFloat
    @Binding var rotation: Double
    let viewSize: CGSize
    
    @State private var dragOffset = CGSize.zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastRotation: Double = 0.0
    @State private var tempRotation: Double = 0.0
    
    var body: some View {
        Text(text)
            .font(.custom(font, size: fontSize * scale))
            .foregroundColor(color)
            .rotationEffect(.degrees(rotation))
            .position(x: position.x + dragOffset.width, y: position.y + dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        var newPosition = CGPoint(
                            x: position.x + dragOffset.width,
                            y: position.y + dragOffset.height
                        )
                        
                        // Keep within bounds with padding
                        newPosition.x = min(max(newPosition.x, 30), viewSize.width - 30)
                        newPosition.y = min(max(newPosition.y, 30), viewSize.height - 30)
                        
                        position = newPosition
                        dragOffset = .zero
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = lastScale * value
                    }
                    .onEnded { value in
                        lastScale = scale
                    }
            )
            .gesture(
                RotationGesture()
                    .onChanged { value in
                        rotation = lastRotation + value.degrees
                    }
                    .onEnded { value in
                        lastRotation = rotation
                    }
            )
    }
}
struct TextInputSheet: View {
    
    @Binding var text: String
    @Binding var fontSize: CGFloat
    @Binding var font: String
    @Binding var color: Color
    let fonts: [String]
    let onSave: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            
            ZStack {
                
                // BACKGROUND
                Image("app_bg_image")
                    .resizable()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: TEXT INPUT
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Text")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            TextField("Enter text", text: $text)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .focused($isFocused)
                        }
                        
                        // MARK: FONT SIZE
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Font Size")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            HStack {
                                Slider(value: $fontSize, in: 12...72)
                                Text("\(Int(fontSize))")
                                    .foregroundColor(.white)
                                    .frame(width: 40)
                            }
                        }
                        
                        // MARK: FONT PICKER
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Font")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(fonts, id: \.self) { fontName in
                                        Text(fontName)
                                            .font(.custom(fontName, size: 16))
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(
                                                font == fontName
                                                ? Color.blue
                                                : Color.white.opacity(0.2)
                                            )
                                            .cornerRadius(8)
                                            .onTapGesture {
                                                font = fontName
                                            }
                                    }
                                }
                            }
                        }
                        
                        // MARK: COLOR PICKER (ATTRACTIVE UI)
                        VStack(alignment: .leading, spacing: 12) {
                            
                            Text("Color")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            HStack(spacing: 12) {
                                
                                // ✅ LIVE COLOR PREVIEW
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                
                                // ✅ SYSTEM COLOR PICKER (CLEAN STYLE)
                                ColorPicker(
                                    "Choose Color",
                                    selection: $color,
                                    supportsOpacity: true
                                )
                                .labelsHidden()
                                .scaleEffect(1.2)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(14)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
                
                // ✅ HIDE KEYBOARD ON SCROLL / DRAG
                .gesture(
                    DragGesture().onChanged { _ in
                        isFocused = false
                    }
                )
                
                // ✅ TAP OUTSIDE
                .onTapGesture {
                    isFocused = false
                }
            }
            
            // NAVBAR
            .navigationTitle("Add Text")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isFocused = false
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !text.isEmpty {
                            onSave()
                        }
                        isFocused = false
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        
        // AUTO FOCUS
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
}

//
//  BlurDrawView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 23/03/26.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct BlurDrawView: View {
    
    let image: UIImage
    let onImageEdited: (UIImage) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var blurPoints: [BlurPoint] = []
    @State private var blurRadius: CGFloat = 40
    @State private var imageViewSize = CGSize.zero
    
    @State private var blurredFullImage: UIImage?
    
    struct BlurPoint: Identifiable {
        let id = UUID()
        let point: CGPoint
        let radius: CGFloat
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Top Bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    Text("Blur")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button { saveBlurredImage() } label: {
                        Text("Save")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                // MARK: - Canvas
                GeometryReader { geometry in
                    let size = geometry.size
                    
                    ZStack {
                        Color.clear
                        
                        // ✅ CENTERED IMAGE CONTAINER
                        ZStack {
                            
                            // Original Image
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                            
                            // Blur Overlay
                            if let blurred = blurredFullImage {
                                Image(uiImage: blurred)
                                    .resizable()
                                    .scaledToFit()
                                    .mask(
                                        Canvas { context, _ in
                                            for point in blurPoints {
                                                let rect = CGRect(
                                                    x: point.point.x - point.radius,
                                                    y: point.point.y - point.radius,
                                                    width: point.radius * 2,
                                                    height: point.radius * 2
                                                )
                                                
                                                context.fill(
                                                    Path(ellipseIn: rect),
                                                    with: .radialGradient(
                                                        Gradient(colors: [.white, .white.opacity(0)]),
                                                        center: CGPoint(x: rect.midX, y: rect.midY),
                                                        startRadius: 0,
                                                        endRadius: point.radius
                                                    )
                                                )
                                            }
                                        }
                                    )
                            }
                        }
                        .frame(width: size.width, height: size.height, alignment: .center) // 🔥 KEY FIX
                    }
                    .onAppear {
                        imageViewSize = size
                        generateFullBlur()
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                blurPoints.append(
                                    BlurPoint(
                                        point: value.location,
                                        radius: blurRadius
                                    )
                                )
                            }
                    )
                }
                .padding(15)
                
                Spacer()
                
                // MARK: - Controls
                VStack(spacing: 20) {
                    
                    VStack(alignment: .leading) {
                        Text("Blur Radius: \(Int(blurRadius))")
                            .foregroundColor(.white)
                        
                        Slider(value: $blurRadius, in: 20...80)
                            .tint(.white)
                    }
                    .padding(.horizontal, 40)
                    
                    Button {
                        blurPoints.removeAll()
                    } label: {
                        Text("Clear All")
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    // MARK: - Generate Full Blur Image
    private func generateFullBlur() {
        guard let ciImage = CIImage(image: image) else { return }
        
        let context = CIContext()
        let filter = CIFilter.gaussianBlur()
        
        let clamped = ciImage.clampedToExtent()
        filter.inputImage = clamped
        filter.radius = 25
        
        guard let output = filter.outputImage else { return }
        
        let cropped = output.cropped(to: ciImage.extent)
        
        if let cgImage = context.createCGImage(cropped, from: ciImage.extent) {
            blurredFullImage = UIImage(cgImage: cgImage)
        }
    }
    
    // MARK: - Save Final Image
    private func saveBlurredImage() {
        
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let final = renderer.image { ctx in
            
            image.draw(in: CGRect(origin: .zero, size: image.size))
            
            guard let blurred = blurredFullImage else { return }
            
            let scaleX = image.size.width / imageViewSize.width
            let scaleY = image.size.height / imageViewSize.height
            
            for point in blurPoints {
                
                let scaledPoint = CGPoint(
                    x: point.point.x * scaleX,
                    y: point.point.y * scaleY
                )
                
                let scaledRadius = point.radius * min(scaleX, scaleY)
                
                let rect = CGRect(
                    x: scaledPoint.x - scaledRadius,
                    y: scaledPoint.y - scaledRadius,
                    width: scaledRadius * 2,
                    height: scaledRadius * 2
                )
                
                ctx.cgContext.saveGState()
                
                ctx.cgContext.addEllipse(in: rect) // ✅ Circle instead of square
                ctx.cgContext.clip()
                
                blurred.draw(in: CGRect(origin: .zero, size: image.size))
                
                ctx.cgContext.restoreGState()
            }
        }
        
        onImageEdited(final)
        dismiss()
    }
}

// MARK: - BlurPreviewView
struct BlurPreviewView: View {
    let image: UIImage
    let point: CGPoint
    let radius: CGFloat
    let viewSize: CGSize
    
    @State private var blurredImage: UIImage?
    
    var body: some View {
        if let blurred = blurredImage {
            Image(uiImage: blurred)
                .resizable()
                .scaledToFill()
                .frame(width: radius * 2, height: radius * 2)
                .position(point)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.clear)
                .frame(width: radius * 2, height: radius * 2)
                .position(point)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .onAppear {
                    generateBlurPreview()
                }
        }
    }
    
    private func generateBlurPreview() {
        // Calculate the area to blur
        let scaleX = image.size.width / viewSize.width
        let scaleY = image.size.height / viewSize.height
        
        let scaledRadius = radius * min(scaleX, scaleY)
        let scaledPoint = CGPoint(
            x: point.x * scaleX,
            y: point.y * scaleY
        )
        
        let blurRect = CGRect(
            x: scaledPoint.x - scaledRadius,
            y: scaledPoint.y - scaledRadius,
            width: scaledRadius * 2,
            height: scaledRadius * 2
        )
        
        // Ensure rect is within image bounds
        let validRect = blurRect.intersection(CGRect(origin: .zero, size: image.size))
        
        if validRect.width > 0 && validRect.height > 0 {
            // Crop the area and apply blur
            if let cgImage = image.cgImage?.cropping(to: validRect) {
                let uiCropped = UIImage(cgImage: cgImage)
                // FIXED: Use the improved blur function
                if let blurred = applyBlurWithoutColorTint(to: uiCropped, radius: radius) {
                    DispatchQueue.main.async {
                        self.blurredImage = blurred
                    }
                }
            }
        }
    }
    
    // FIXED: Apply blur without color tint at edges
    private func applyBlurWithoutColorTint(to image: UIImage, radius: CGFloat) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // IMPORTANT: Clamp the image to extend its edges to prevent dark/color tint at borders
        let clampedImage = ciImage.clampedToExtent()
        
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = clampedImage
        filter.radius = Float(radius)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Crop back to the original extent to remove the clamped edges
        let croppedImage = outputImage.cropped(to: ciImage.extent)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(croppedImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

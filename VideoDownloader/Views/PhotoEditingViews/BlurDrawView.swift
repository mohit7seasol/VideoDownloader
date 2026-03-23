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
    @State private var blurRadius: CGFloat = 15
    @State private var imageViewSize = CGSize.zero
    
    struct BlurPoint: Identifiable {
        let id = UUID()
        let point: CGPoint
        let radius: CGFloat
    }
    
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
                    
                    Text("Blur".localized(LocalizationService.shared.language))
                        .font(.custom("Poppins-Black", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        saveBlurredImage()
                    } label: {
                        Text("Save".localized(LocalizationService.shared.language))
                            .font(.custom("Urbanist-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 0)
                .padding(.bottom, 20)
                
                // Blur Canvas with real-time blur preview
                GeometryReader { geometry in
                    let size = geometry.size
                    ZStack {
                        // Base image
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: size.width, height: size.height)
                            .onAppear {
                                imageViewSize = size
                            }
                        
                        // Apply real-time blur preview
                        ForEach(blurPoints) { blurPoint in
                            BlurPreviewView(
                                image: image,
                                point: blurPoint.point,
                                radius: blurPoint.radius,
                                viewSize: size
                            )
                        }
                    }
                    .frame(width: size.width, height: size.height)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newPoint = BlurPoint(point: value.location, radius: blurRadius)
                                blurPoints.append(newPoint)
                            }
                    )
                }
                .padding(.horizontal, 15)
                .padding(.top, 15)
                .padding(.bottom, 15)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
                // Controls
                VStack(spacing: 20) {
                    // Blur Radius Slider
                    VStack(alignment: .leading) {
                        Text("Blur Radius: \(Int(blurRadius))")
                            .foregroundColor(.white)
                            .font(.custom("Urbanist-Medium", size: 14))
                        Slider(value: $blurRadius, in: 10...50, step: 1)
                            .tint(.white)
                    }
                    .padding(.horizontal, 40)
                    
                    // Clear Button
                    Button {
                        blurPoints.removeAll()
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
                .padding(.bottom, 50)
            }
        }
    }
    
    private func saveBlurredImage() {
        // Calculate scale factors between display size and actual image size
        let scaleX = image.size.width / imageViewSize.width
        let scaleY = image.size.height / imageViewSize.height
        
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let finalImage = renderer.image { ctx in
            // Draw original image
            image.draw(in: CGRect(origin: .zero, size: image.size))
            
            // Apply blur to each point with proper scaling
            for blurPoint in blurPoints {
                let scaledRadius = blurPoint.radius * min(scaleX, scaleY)
                let scaledPoint = CGPoint(
                    x: blurPoint.point.x * scaleX,
                    y: blurPoint.point.y * scaleY
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
                    // Crop the area to blur
                    if let cgImage = image.cgImage?.cropping(to: validRect) {
                        let uiCropped = UIImage(cgImage: cgImage)
                        if let blurred = applyBlur(to: uiCropped, radius: blurPoint.radius) {
                            blurred.draw(in: validRect)
                        }
                    }
                }
            }
        }
        
        onImageEdited(finalImage)
        dismiss()
    }
    
    private func applyBlur(to image: UIImage, radius: CGFloat) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = ciImage
        filter.radius = Float(radius)
        
        guard let outputImage = filter.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
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
                .scaledToFit()
                .frame(width: radius * 2, height: radius * 2)
                .position(point)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color.clear)
                .frame(width: radius * 2, height: radius * 2)
                .position(point)
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
        
        // Crop the area and apply blur
        if let cgImage = image.cgImage?.cropping(to: blurRect) {
            let uiCropped = UIImage(cgImage: cgImage)
            if let blurred = applyBlur(to: uiCropped, radius: radius) {
                DispatchQueue.main.async {
                    self.blurredImage = blurred
                }
            }
        }
    }
    
    private func applyBlur(to image: UIImage, radius: CGFloat) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = ciImage
        filter.radius = Float(radius)
        
        guard let outputImage = filter.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

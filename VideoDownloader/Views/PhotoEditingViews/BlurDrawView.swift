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
                // Top Bar - with padding top 0
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
                .padding(.top, 0) // Set to 0
                .padding(.bottom, 20)
                
                // Blur Canvas with left and right padding 15
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
                        
                        // Draw blur points - show actual blur preview
                        ForEach(blurPoints) { blurPoint in
                            Circle()
                                .fill(Color.clear)
                                .frame(width: blurPoint.radius * 2, height: blurPoint.radius * 2)
                                .position(blurPoint.point)
                                .background(
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: size.width, height: size.height)
                                        .position(x: size.width / 2, y: size.height / 2)
                                        .mask(
                                            Circle()
                                                .frame(width: blurPoint.radius * 2, height: blurPoint.radius * 2)
                                                .position(blurPoint.point)
                                        )
                                        .blur(radius: blurPoint.radius / 2)
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
                .padding(.horizontal, 15) // Left and right padding 15
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
                        Text("Clear".localized(LocalizationService.shared.language))
                            .foregroundColor(.red)
                            .font(.custom("Urbanist-Medium", size: 14))
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private func saveBlurredImage() {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let finalImage = renderer.image { ctx in
            // Draw original image
            image.draw(in: CGRect(origin: .zero, size: image.size))
            
            // Calculate scale factors
            let scaleX = image.size.width / imageViewSize.width
            let scaleY = image.size.height / imageViewSize.height
            
            // Apply blur to each point
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
                
                // Crop the area to blur
                if let cgImage = image.cgImage?.cropping(to: blurRect) {
                    let uiCropped = UIImage(cgImage: cgImage)
                    if let blurred = applyBlur(to: uiCropped, radius: blurPoint.radius) {
                        blurred.draw(in: blurRect)
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

//
//  AdjustView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 23/03/26.
//

import SwiftUI
import CoreImage

struct AdjustView: View {
    
    let image: UIImage
    let onImageEdited: (UIImage) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var brightness: Double = 0
    @State private var contrast: Double = 1
    @State private var saturation: Double = 1
    @State private var adjustedImage: UIImage?
    
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
                    
                    Text("Adjust".localized(LocalizationService.shared.language))
                        .font(.custom("Poppins-Black", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        // Fix: adjustedImage ?? image returns non-optional UIImage
                        let finalImage = adjustedImage ?? image
                        onImageEdited(finalImage)
                        dismiss()
                    } label: {
                        Text("Save".localized(LocalizationService.shared.language))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                Spacer()
                
                // Preview Image
                if let adjusted = adjustedImage {
                    Image(uiImage: adjusted)
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.height - 350)
                } else {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.height - 350)
                }
                
                Spacer()
                
                // Adjustment Sliders
                VStack(spacing: 25) {
                    // Brightness
                    VStack(alignment: .leading) {
                        Text("Brightness: \(Int(brightness * 100))%")
                            .foregroundColor(.white)
                        Slider(value: $brightness, in: -0.5...0.5, step: 0.01)
                            .tint(.white)
                    }
                    
                    // Contrast
                    VStack(alignment: .leading) {
                        Text("Contrast: \(Int(contrast * 100))%")
                            .foregroundColor(.white)
                        Slider(value: $contrast, in: 0...2, step: 0.01)
                            .tint(.white)
                    }
                    
                    // Saturation
                    VStack(alignment: .leading) {
                        Text("Saturation: \(Int(saturation * 100))%")
                            .foregroundColor(.white)
                        Slider(value: $saturation, in: 0...2, step: 0.01)
                            .tint(.white)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .onChange(of: brightness) { _ in updateImage() }
        .onChange(of: contrast) { _ in updateImage() }
        .onChange(of: saturation) { _ in updateImage() }
    }
    
    private func updateImage() {
        guard let ciImage = CIImage(image: image) else { return }
        
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.brightness = Float(brightness)
        filter.contrast = Float(contrast)
        filter.saturation = Float(saturation)
        
        guard let outputImage = filter.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            return
        }
        
        adjustedImage = UIImage(cgImage: cgImage)
    }
}

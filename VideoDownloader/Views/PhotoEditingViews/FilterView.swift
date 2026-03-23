//
//  FilterView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 23/03/26.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct FilterView: View {
    
    let image: UIImage
    let onImageEdited: (UIImage) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedFilter = "Original"
    @State private var filteredImage: UIImage?
    
    let filters = [
        "Original", "Sepia", "Mono", "Noir", "Fade", "Chrome",
        "Vintage", "Dramatic", "Cool", "Warm", "Boost", "Vivid",
        "Vivid Warm", "Vivid Cool", "Process", "Transfer", "Instant",
        "Tonal", "Bloom", "Gloom", "Sharpen", "Crystallize",
        "Pixelate", "Comic", "Edges", "Posterize", "Vignette"
    ]
    
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
                    
                    Text("Filters".localized(LocalizationService.shared.language))
                        .font(.custom("Poppins-Black", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        let finalImage = filteredImage ?? image
                        onImageEdited(finalImage)
                        dismiss()
                    } label: {
                        Text("Save".localized(LocalizationService.shared.language))
                            .font(.custom("Urbanist-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                Spacer()
                
                // Filtered Image
                if let filtered = filteredImage {
                    Image(uiImage: filtered)
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.height - 250)
                        .cornerRadius(12)
                } else {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.height - 250)
                        .cornerRadius(12)
                }
                
                Spacer()
                
                // Filter List
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(filters, id: \.self) { filter in
                            VStack {
                                Image(uiImage: applyFilter(image, filter: filter))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(8)
                                
                                Text(filter)
                                    .font(.custom("Urbanist-Medium", size: 10))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: 80)
                            }
                            .onTapGesture {
                                selectedFilter = filter
                                filteredImage = applyFilter(image, filter: filter)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedFilter == filter ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func applyFilter(_ image: UIImage, filter: String) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        
        let context = CIContext()
        var outputImage: CIImage?
        
        switch filter {
        // Basic Filters
        case "Sepia":
            let filter = CIFilter.sepiaTone()
            filter.inputImage = ciImage
            filter.intensity = 0.8
            outputImage = filter.outputImage
            
        case "Mono":
            let filter = CIFilter.photoEffectMono()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "Noir":
            let filter = CIFilter.photoEffectNoir()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "Fade":
            let filter = CIFilter.photoEffectFade()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "Chrome":
            let filter = CIFilter.photoEffectChrome()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        // Photo Effect Filters
        case "Vintage":
            let filter = CIFilter.photoEffectTransfer()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "Dramatic":
            let filter = CIFilter.photoEffectProcess()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "Instant":
            let filter = CIFilter.photoEffectInstant()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "Tonal":
            let filter = CIFilter.photoEffectTonal()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        // Color Adjustment Filters
        case "Cool":
            let filter = CIFilter.temperatureAndTint()
            filter.inputImage = ciImage
            filter.targetNeutral = CIVector(x: 6500, y: 0)
            outputImage = filter.outputImage
            
        case "Warm":
            let filter = CIFilter.temperatureAndTint()
            filter.inputImage = ciImage
            filter.targetNeutral = CIVector(x: 4500, y: 0)
            outputImage = filter.outputImage
            
        case "Boost":
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = 1.3
            filter.contrast = 1.1
            filter.brightness = 0.05
            outputImage = filter.outputImage
            
        case "Vivid":
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = 1.5
            filter.contrast = 1.2
            filter.brightness = 0
            outputImage = filter.outputImage
            
        case "Vivid Warm":
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = 1.4
            filter.contrast = 1.1
            filter.brightness = 0.05
            outputImage = filter.outputImage
            if var output = outputImage {
                let warmFilter = CIFilter.temperatureAndTint()
                warmFilter.inputImage = output
                warmFilter.targetNeutral = CIVector(x: 5000, y: 0)
                outputImage = warmFilter.outputImage
            }
            
        case "Vivid Cool":
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = 1.4
            filter.contrast = 1.1
            filter.brightness = 0
            outputImage = filter.outputImage
            if var output = outputImage {
                let coolFilter = CIFilter.temperatureAndTint()
                coolFilter.inputImage = output
                coolFilter.targetNeutral = CIVector(x: 7000, y: 0)
                outputImage = coolFilter.outputImage
            }
            
        case "Process":
            let filter = CIFilter.photoEffectProcess()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "Transfer":
            let filter = CIFilter.photoEffectTransfer()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        // Stylize Filters
        case "Bloom":
            let filter = CIFilter.bloom()
            filter.inputImage = ciImage
            filter.intensity = 0.8
            filter.radius = 10
            outputImage = filter.outputImage
            
        case "Gloom":
            let filter = CIFilter.gloom()
            filter.inputImage = ciImage
            filter.intensity = 0.8
            filter.radius = 10
            outputImage = filter.outputImage
            
        case "Sharpen":
            let filter = CIFilter.sharpenLuminance()
            filter.inputImage = ciImage
            filter.sharpness = 0.8
            outputImage = filter.outputImage
            
        case "Crystallize":
            let filter = CIFilter.crystallize()
            filter.inputImage = ciImage
            filter.radius = 15
            outputImage = filter.outputImage
            
        case "Pixelate":
            let filter = CIFilter.pixellate()
            filter.inputImage = ciImage
            filter.scale = 20
            outputImage = filter.outputImage
            
        case "Comic":
            let filter = CIFilter.comicEffect()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "Edges":
            let filter = CIFilter.edges()
            filter.inputImage = ciImage
            filter.intensity = 1.0
            outputImage = filter.outputImage
            
        case "Posterize":
            let filter = CIFilter.colorPosterize()
            filter.inputImage = ciImage
            filter.levels = 6
            outputImage = filter.outputImage
            
        case "Vignette":
            let filter = CIFilter.vignette()
            filter.inputImage = ciImage
            filter.intensity = 0.8
            filter.radius = 1.5
            outputImage = filter.outputImage
            
        default:
            return image
        }
        
        guard let output = outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
}

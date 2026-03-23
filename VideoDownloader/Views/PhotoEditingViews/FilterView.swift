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
    
    let filters = ["Original", "Sepia", "Mono", "Vintage", "Dramatic", "Cool", "Warm"]
    
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
                    
                    Text("Filters".localized(LocalizationService.shared.language))
                        .font(.custom("Poppins-Black", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        // Fix: filteredImage ?? image returns non-optional UIImage
                        let finalImage = filteredImage ?? image
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
                
                // Filtered Image
                if let filtered = filteredImage {
                    Image(uiImage: filtered)
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.height - 250)
                } else {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.height - 250)
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
                                    .font(.caption)
                                    .foregroundColor(.white)
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
        case "Sepia":
            let filter = CIFilter.sepiaTone()
            filter.inputImage = ciImage
            filter.intensity = 0.8
            outputImage = filter.outputImage
            
        case "Mono":
            let filter = CIFilter.photoEffectMono()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "Vintage":
            let filter = CIFilter.photoEffectTransfer()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "Dramatic":
            let filter = CIFilter.photoEffectProcess()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "Cool":
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = 0.8
            filter.brightness = 0.1
            filter.contrast = 1.1
            outputImage = filter.outputImage
            
        case "Warm":
            let filter = CIFilter.colorControls()
            filter.inputImage = ciImage
            filter.saturation = 1.2
            filter.brightness = 0.1
            filter.contrast = 1.0
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

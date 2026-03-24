//
//  CropView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 23/03/26.
//

import SwiftUI
import CropViewController

struct CropView: View {
    
    let image: UIImage
    let onImageEdited: (UIImage) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var croppedImage: UIImage?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar - Fixed with padding top 0
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    Text("Crop".localized(LocalizationService.shared.language))
                        .font(.custom("Poppins-Black", size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        if let cropped = croppedImage {
                            onImageEdited(cropped)
                            dismiss()
                        }
                    } label: {
                        Text("Save".localized(LocalizationService.shared.language))
                            .font(.custom("Urbanist-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 0) // Changed from 50 to 0
                .padding(.bottom, 20)
                
                // Crop View
                CropViewControllerWrapper(image: image, croppedImage: $croppedImage)
                    .frame(height: UIScreen.main.bounds.height - 200)
                
                Spacer()
            }
        }
    }
}

// MARK: - CropViewControllerWrapper
struct CropViewControllerWrapper: UIViewControllerRepresentable {
    let image: UIImage
    @Binding var croppedImage: UIImage?
    
    func makeUIViewController(context: Context) -> CropViewController {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }
    
    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CropViewControllerDelegate {
        let parent: CropViewControllerWrapper
        
        init(_ parent: CropViewControllerWrapper) {
            self.parent = parent
        }
        
        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            parent.croppedImage = image
        }
        
        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            // Handle cancel
        }
    }
}

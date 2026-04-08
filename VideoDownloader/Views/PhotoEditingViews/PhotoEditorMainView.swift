//
//  PhotoEditorMainView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 23/03/26.
//

import SwiftUI
import Photos

// MARK: - Feature Enum
enum PhotoFeature: Int, Identifiable {
    case draw = 0
    case crop
    case text
    case filter
    case adjust
    case blur
    
    var id: Int { rawValue }
}

// MARK: - Main View
struct PhotoEditorMainView: View {
    
    let asset: PHAsset
    @Environment(\.dismiss) var dismiss
    
    @State private var image: UIImage?
    @State private var editedImage: UIImage?
    @State private var selectedFeature: PhotoFeature?
    @State private var showDoneAlert = false
    
    var body: some View {
        ZStack {
            // Background
            Image("app_bg_image")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: NAVBAR
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    
                    Text("Photo Editor".localized(LocalizationService.shared.language))
                        .font(.custom("Poppins-Black", size: 20))
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 0) // Set to 0 to match PhotoChooseView
                
                // MARK: IMAGE VIEW with left and right padding 15
                if let displayImage = editedImage ?? image {
                    Image(uiImage: displayImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .padding(.horizontal, 15) // Left and right padding 15
                        .padding(.top, 20)
                } else {
                    Spacer()
                    ProgressView().tint(.white)
                    Spacer()
                }
                
                Spacer()
                
                // MARK: FEATURES TOOLBAR
                PhotoFeaturesView { feature in
                    selectedFeature = feature
                }
                
                // MARK: DONE BUTTON
                Button {
                    applyChanges()
                } label: {
                    Text("Done".localized(LocalizationService.shared.language))
                        .font(.custom("Urbanist-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "1973E8"),
                                    Color(hex: "0E4082")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(25)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadImage()
        }
        .fullScreenCover(item: $selectedFeature) { feature in
            if Device.isIpad {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    featureView(feature)
                        .frame(maxWidth: 600) // 🔥 control width here
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            } else {
                featureView(feature)
            }
        }
        .alert("Success".localized(LocalizationService.shared.language), isPresented: $showDoneAlert) {
            Button("OK".localized(LocalizationService.shared.language), role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Image edited successfully!".localized(LocalizationService.shared.language))
        }
    }
    
    // MARK: Load Image
    private func loadImage() {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 1200, height: 1200),
            contentMode: .aspectFit,
            options: options
        ) { img, _ in
            DispatchQueue.main.async {
                self.image = img
            }
        }
    }
    
    // MARK: Apply Changes
    private func applyChanges() {
        if let finalImage = editedImage ?? image {
            UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
            showDoneAlert = true
        }
    }
    
    // MARK: Feature Navigation
    @ViewBuilder
    private func featureView(_ feature: PhotoFeature) -> some View {
        if let currentImage = editedImage ?? image {
            switch feature {
            case .draw:
                DrawView(image: currentImage) { editedImg in
                    self.editedImage = editedImg
                }
            case .crop:
                CropView(image: currentImage) { editedImg in
                    self.editedImage = editedImg
                }
            case .text:
                TextEditorView(image: currentImage) { editedImg in
                    self.editedImage = editedImg
                }
            case .filter:
                FilterView(image: currentImage) { editedImg in
                    self.editedImage = editedImg
                }
            case .adjust:
                AdjustView(image: currentImage) { editedImg in
                    self.editedImage = editedImg
                }
            case .blur:
                BlurDrawView(image: currentImage) { editedImg in
                    self.editedImage = editedImg
                }
            }
        }
    }
}
// MARK: - PhotoFeaturesView
struct PhotoFeaturesView: View {
    
    let onTap: (PhotoFeature) -> Void
    
    let icons = ["pencil", "crop", "textformat", "camera.filters", "slider.horizontal.3", "drop"]
    let labels = ["Draw", "Crop", "Text", "Filter", "Adjust", "Blur"]
    
    var body: some View {
        if Device.isIpad {
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(0..<icons.count, id: \.self) { i in
                            Button {
                                if let feature = PhotoFeature(rawValue: i) {
                                    onTap(feature)
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: icons[i])
                                        .foregroundColor(.white)
                                        .font(.system(size: 24))
                                        .frame(width: 50, height: 50)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(12)
                                    
                                    Text(labels[i])
                                        .font(.custom("Urbanist-Medium", size: 11))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .frame(
                        minWidth: geo.size.width,
                        alignment: .center
                    )
                    .padding(.horizontal, 20)
                }
            }
            .frame(height: 100)
            .padding(.vertical, 12)
            .padding(.bottom, 10)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<icons.count, id: \.self) { i in
                        Button {
                            if let feature = PhotoFeature(rawValue: i) {
                                onTap(feature)
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: icons[i])
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                                    .frame(width: 50, height: 50)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(12)
                                
                                Text(labels[i])
                                    .font(.custom("Urbanist-Medium", size: 11))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 12)
            .padding(.bottom, 10)
        }
    }
}

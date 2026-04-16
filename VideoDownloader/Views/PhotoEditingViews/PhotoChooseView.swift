//
//  PhotoChooseView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 23/03/26.
//

import SwiftUI
import Photos
import PhotosUI

// MARK: - PhotoSelectionTypes Enum
enum PhotoSelectionTypes {
    case photoEdit
    case photoBGRemover
}

// MARK: - PhotoAsset Model
struct PhotoAsset: Identifiable {
    let id = UUID()
    let asset: PHAsset
}

// MARK: - PhotoThumbnailView
struct PhotoThumbnailView: View {
    let asset: PhotoAsset
    @State private var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: (UIScreen.main.bounds.width - 40) / 3, height: (UIScreen.main.bounds.width - 40) / 3)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: (UIScreen.main.bounds.width - 40) / 3, height: (UIScreen.main.bounds.width - 40) / 3)
                    .cornerRadius(12)
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(
            for: asset.asset,
            targetSize: CGSize(width: 300, height: 300),
            contentMode: .aspectFill,
            options: options
        ) { img, _ in
            if let img = img {
                DispatchQueue.main.async {
                    self.image = img
                }
            }
        }
    }
}

// MARK: - PhotoChooseView
struct PhotoChooseView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var images: [PhotoAsset] = []
    @State private var isLoading = false
    @State private var selectedImage: PhotoAsset?
    @State private var navigateToEditor = false
    @State private var navigateToBGEraser = false
    @State private var showPermissionAlert = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @StateObject private var photoObserver = PhotoLibraryObserver()
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var selectionType: PhotoSelectionTypes
    
    let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "App"
    
    init(selectionType: PhotoSelectionTypes = .photoEdit) {
        self.selectionType = selectionType
    }
    
    var body: some View {
        ZStack {
            Image("app_bg_image")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // NAVBAR
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    
                    Text(getTitle())
                        .font(.custom("Poppins-Black", size: 20))
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    // Manage Button - Only show for limited access
                    if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
                        Button {
                            showPermissionManagement()
                        } label: {
                            Text("Manage".localized(self.language))
                                .font(.custom("Urbanist-Medium", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 0)
                
                // Limited Access Message
                if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
                    LimitAccessPhotoView(appName: appName)
                }
                
                if isLoading {
                    Spacer()
                    ProgressView().tint(.white)
                    Spacer()
                } else if images.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("No Photos Found".localized(self.language))
                            .font(.custom("Poppins-Black", size: 18))
                            .foregroundColor(.white)
                        
                        Text("Tap below to access your photos".localized(self.language))
                            .font(.custom("Urbanist-Medium", size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    
                    Button {
                        checkPermission()
                    } label: {
                        Text("Access Photos".localized(self.language))
                            .font(.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(width: 150)
                            .frame(height: 50)
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
                    .padding(.bottom, 40)
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 10) {
                            ForEach(images) { img in
                                PhotoThumbnailView(asset: img)
                                    .onTapGesture {
                                        selectedImage = img
                                        navigateToDestination()
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            photoObserver.onChange = {
                loadImages()
            }
            checkPermission()
        }
        .alert("Permission Required".localized(self.language), isPresented: $showPermissionAlert) {
            Button("Cancel".localized(self.language), role: .cancel) { }
            Button("Settings".localized(self.language)) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please grant photo library access to select photos".localized(self.language))
        }
        .navigationDestination(isPresented: $navigateToEditor) {
            if let img = selectedImage {
                PhotoEditorMainView(asset: img.asset)
            }
        }
        .navigationDestination(isPresented: $navigateToBGEraser) {
            if let img = selectedImage {
                let image = getUIImage(from: img.asset)
                BgEraserView(image: image ?? UIImage())
            }
        }
    }
    
    private func getTitle() -> String {
        switch selectionType {
        case .photoEdit:
            return "Select Photo".localized(self.language)
        case .photoBGRemover:
            return "Select Photo".localized(self.language)
        }
    }
    
    private func navigateToDestination() {
        switch selectionType {
        case .photoEdit:
            navigateToEditor = true
        case .photoBGRemover:
            navigateToBGEraser = true
        }
    }
    
    private func getUIImage(from asset: PHAsset) -> UIImage? {
        var resultImage: UIImage?
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            resultImage = image
        }
        return resultImage
    }
    
    private func showPermissionManagement() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: rootViewController)
        }
    }
    
    private func checkPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        if status == .authorized || status == .limited {
            loadImages()
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        loadImages()
                    } else {
                        showPermissionAlert = true
                    }
                }
            }
        } else {
            showPermissionAlert = true
        }
    }
    
    private func loadImages() {
        isLoading = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let fetch = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var temp: [PhotoAsset] = []
        
        fetch.enumerateObjects { asset, _, _ in
            temp.append(PhotoAsset(asset: asset))
        }
        
        images = temp
        isLoading = false
    }
}

// MARK: - LimitAccessPhotoView
struct LimitAccessPhotoView: View {
    let appName: String
    @State private var showManageOptions = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Select Photo".localized(self.language))
                    .font(.custom("Urbanist-Medium", size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Button {
                    showManageOptions = true
                } label: {
                    Text("Manage".localized(self.language))
                        .font(.custom("Urbanist-Medium", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(12)
                }
            }
            
            Text("\("You've given".localized(self.language)) \(appName) \("limited access to select number of photos".localized(self.language))")
                .font(.custom("Urbanist-Medium", size: 13))
                .foregroundColor(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .alert("Manage".localized(self.language), isPresented: $showManageOptions) {
            Button("Select More Photos".localized(self.language)) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: rootViewController)
                }
            }
            
            Button("Change Settings".localized(self.language)) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Cancel".localized(self.language), role: .cancel) { }
        } message: {
            Text("\("You've given".localized(self.language)) \(appName) \("limited access to select number of photos".localized(self.language))")
        }
    }
}

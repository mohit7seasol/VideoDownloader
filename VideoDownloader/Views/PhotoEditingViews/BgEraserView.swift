//
//  BgEraserView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 15/04/26.
//

import SwiftUI
import BackgroundRemoval

struct BgEraserView: View {
    
    let image: UIImage
    
    @Environment(\.dismiss) var dismiss
    
    @State private var outputImage: UIImage?
    @State private var isProcessing = false
    @State private var navigateNext = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    // MARK: - Preview Size Calculation (Matching AddNewBGView)
    private var previewSize: CGSize {
        let containerHeight: CGFloat = Device.isIpad
            ? UIScreen.main.bounds.height * 0.65
            : UIScreen.main.bounds.height * 0.58
        
        let maxWidth = UIScreen.main.bounds.width - 40
        let aspectRatio = image.size.width / image.size.height
        
        var width = containerHeight * aspectRatio
        var height = containerHeight
        
        if width > maxWidth {
            width = maxWidth
            height = width / aspectRatio
        }
        
        return CGSize(width: width, height: height)
    }
    
    var body: some View {
        if Device.isIpad {
            GeometryReader { geometry in
                ZStack {
                    Image("app_bg_image")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        
                        // HEADER
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .font(.system(size: 22, weight: .semibold))
                            }
                            
                            Text("Background Remove".localized(self.language))
                                .foregroundColor(.white)
                                .font(.custom("Urbanist-Bold", size: 24))
                            
                            Spacer()
                        }
                        .padding(.top, UIApplication.shared.safeAreaTop)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                        
                        // IMAGE PREVIEW (Matching AddNewBGView style)
                        ZStack {
                            if let outputImage {
                                Image(uiImage: outputImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: previewSize.width, height: previewSize.height)
                            } else {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: previewSize.width, height: previewSize.height)
                            }
                            
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(1.5)
                            }
                        }
                        .frame(height: Device.isIpad ? UIScreen.main.bounds.height * 0.65 : 380)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(24)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 20)
                        
                        // BUTTON
                        Button {
                            removeBG()
                        } label: {
                            HStack(spacing: 12) {
                                if outputImage == nil {
                                    Image(systemName: "wand.and.stars")
                                        .font(.system(size: 22))
                                } else {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 22))
                                }
                                
                                Text(outputImage == nil ? "Remove Background".localized(self.language) : "Next".localized(self.language))
                                    .font(.custom("Urbanist-Bold", size: 18))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 65)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#1973E8"), Color(hex: "#0E4082")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(30)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 660)
                        
                        NavigationLink(
                            destination: AddNewBGView(image: outputImage ?? image),
                            isActive: $navigateNext
                        ) { EmptyView() }
                    }
                }
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
            }
        } else {
            // iPhone Layout
            ZStack {
                Image("app_bg_image")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // HEADER
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        
                        Text("Background Remove".localized(self.language))
                            .foregroundColor(.white)
                            .font(.custom("Urbanist-Bold", size: 18))
                        
                        Spacer()
                    }
                    .padding(.top, UIApplication.shared.safeAreaTop)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    
                    // IMAGE PREVIEW (Matching AddNewBGView style)
                    ZStack {
                        if let outputImage {
                            Image(uiImage: outputImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: previewSize.width, height: previewSize.height)
                        } else {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: previewSize.width, height: previewSize.height)
                        }
                        
                        if isProcessing {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.3)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.58)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(24)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer(minLength: 20)
                    
                    // BUTTON
                    Button {
                        removeBG()
                    } label: {
                        HStack(spacing: 12) {
                            if outputImage == nil {
                                Image(systemName: "wand.and.stars")
                                    .font(.system(size: 18))
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 18))
                            }
                            
                            Text(outputImage == nil ? "Remove Background".localized(self.language) : "Next".localized(self.language))
                                .font(.custom("Urbanist-Bold", size: 16))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#1973E8"), Color(hex: "#0E4082")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(30)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, Device.bottomSafeArea + 20)
                    
                    NavigationLink(
                        destination: AddNewBGView(image: outputImage ?? image),
                        isActive: $navigateNext
                    ) { EmptyView() }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - BG REMOVE
    private func removeBG() {
        if outputImage != nil {
            navigateNext = true
            return
        }
        
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let remover = BackgroundRemoval()
            let result = try? remover.removeBackground(image: image)
            
            DispatchQueue.main.async {
                self.outputImage = result
                self.isProcessing = false
            }
        }
    }
}

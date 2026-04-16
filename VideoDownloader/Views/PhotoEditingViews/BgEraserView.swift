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
    
    var body: some View {
        ZStack {
            Image("app_bg_image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // HEADER
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    
                    Text("Background Remove")
                        .foregroundColor(.white)
                        .font(.custom("Urbanist-Bold", size: 18))
                    
                    Spacer()
                }
                .padding(.top, UIApplication.shared.safeAreaTop)
                .padding(.bottom, 10)
                .padding(.leading, 12)
                .background(Color.clear)
                
                // IMAGE AREA
                ZStack {
                    
                    if let outputImage {
                        Image(uiImage: outputImage)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .frame(height: 400)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // BUTTON
                Button {
                    removeBG()
                } label: {
                    Text(outputImage == nil ? "Remove Bg" : "Next")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(30)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                
                NavigationLink(
                    destination: AddNewBGView(image: outputImage ?? image),
                    isActive: $navigateNext
                ) { EmptyView() }
            }
        }
        .navigationBarHidden(true)
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

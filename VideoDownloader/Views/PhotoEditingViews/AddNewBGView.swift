//
//  AddNewBGView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 15/04/26.
//

import SwiftUI

struct AddNewBGView: View {
    
    let image: UIImage
    
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedBG: UIImage?
    
    let bgList = ["bg1", "bg2"]
    
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
                
                // IMAGE VIEW
                ZStack {
                    
                    if let bg = selectedBG {
                        Image(uiImage: bg)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
                .frame(height: 400)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                // BG OPTIONS
                HStack(spacing: 15) {
                    
                    // NO BG
                    Button {
                        selectedBG = nil
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.4))
                            .frame(width: 70, height: 70)
                            .overlay(Image(systemName: "nosign"))
                    }
                    
                    ForEach(bgList, id: \.self) { bg in
                        Button {
                            selectedBG = UIImage(named: bg)
                        } label: {
                            Image(bg)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 70)
                                .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
                
                // SAVE BUTTON
                Button {
                    saveImage()
                } label: {
                    HStack {
                        Text("Save")
                        Image(systemName: "arrow.down")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(30)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, Device.bottomSafeArea)
            }
            
        }
        .navigationBarHidden(true)
    }
    
    // MARK: SAVE
    private func saveImage() {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let final = renderer.image { ctx in
            if let bg = selectedBG {
                bg.draw(in: CGRect(origin: .zero, size: image.size))
            }
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        
        UIImageWriteToSavedPhotosAlbum(final, nil, nil, nil)
    }
}

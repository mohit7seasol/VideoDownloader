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
    
    @State private var selectedBG: String?
    @State private var isSaved = false
    
    let bgList = ["bg1", "bg2", "bg3", "bg4", "bg5", "bg6", "bg7", "bg8", "bg9"]
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
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
                            .font(.system(size: isIpad ? 22 : 18, weight: .semibold))
                    }
                    
                    Text("Background Remove")
                        .foregroundColor(.white)
                        .font(.custom("Urbanist-Bold", size: isIpad ? 24 : 18))
                    
                    Spacer()
                }
                .padding(.top, UIApplication.shared.safeAreaTop)
                .padding(.horizontal, isIpad ? 24 : 20)
                .padding(.bottom, isIpad ? 20 : 16)
                
                // IMAGE VIEW
                ZStack {
                    if let bgName = selectedBG, let bgImage = UIImage(named: bgName) {
                        Image(uiImage: bgImage)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
                .frame(height: isIpad ? 450 : 380)
                .background(Color.white.opacity(0.08))
                .cornerRadius(24)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer(minLength: 20)
                
                // BG OPTIONS TITLE
                Text("Choose Background")
                    .font(.custom("Urbanist-Bold", size: isIpad ? 20 : 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                
                // BG OPTIONS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        // NO BG Button
                        Button {
                            selectedBG = nil
                        } label: {
                            VStack(spacing: 8) {
                                ZStack(alignment: .topTrailing) {
                                    // Background circle/rectangle
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: isIpad ? 100 : 82, height: isIpad ? 100 : 82)
                                        .overlay(
                                            Image(systemName: "nosign")
                                                .font(.system(size: isIpad ? 32 : 26))
                                                .foregroundColor(.white)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(selectedBG == nil ? Color.blue : Color.clear, lineWidth: 3)
                                        )
                                    
                                    // Selected checkmark for None
                                    if selectedBG == nil {
                                        Image("selected_bg_ic")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: isIpad ? 28 : 24, height: isIpad ? 28 : 24)
                                            .padding(4)
                                            .offset(x: isIpad ? 8 : 6, y: isIpad ? -8 : -6)
                                    }
                                }
                                
                                Text("None")
                                    .font(.custom("Urbanist-Medium", size: isIpad ? 14 : 12))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // BG Options
                        ForEach(bgList, id: \.self) { bg in
                            Button {
                                selectedBG = bg
                            } label: {
                                VStack(spacing: 8) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(bg)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: isIpad ? 100 : 80, height: isIpad ? 100 : 80)
                                            .cornerRadius(16)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(selectedBG == bg ? Color.blue : Color.clear, lineWidth: 3)
                                            )
                                        
                                        // Selected checkmark
                                        if selectedBG == bg {
                                            Image("selected_bg_ic")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: isIpad ? 28 : 24, height: isIpad ? 28 : 24)
                                                .padding(4)
                                                .offset(x: isIpad ? 6 : 4, y: isIpad ? -6 : -4)
                                        }
                                    }
                                    
                                    Text(bg.uppercased())
                                        .font(.custom("Urbanist-Medium", size: isIpad ? 14 : 12))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 20)
                
                // SAVE BUTTON
                Button {
                    saveImage()
                } label: {
                    HStack(spacing: 12) {
                        Text("Save")
                            .font(.custom("Urbanist-Bold", size: isIpad ? 18 : 16))
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: isIpad ? 22 : 18))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: isIpad ? 65 : 55)
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
            }
        }
        .navigationBarHidden(true)
        .alert("Success", isPresented: $isSaved) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Image saved to gallery successfully!")
        }
    }
    
    // MARK: SAVE
    private func saveImage() {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let final = renderer.image { ctx in
            if let bgName = selectedBG, let bgImage = UIImage(named: bgName) {
                bgImage.draw(in: CGRect(origin: .zero, size: image.size))
            }
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        
        UIImageWriteToSavedPhotosAlbum(final, nil, nil, nil)
        isSaved = true
    }
}


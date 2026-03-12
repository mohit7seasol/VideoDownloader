//
//  AddHashTagView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 12/03/26.
//

import SwiftUI

struct AddHashTagView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showAddHashtagSheet = false
    @State private var hashtagText = ""
    @FocusState private var isTextViewFocused: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background Image
            Image("app_bg_image")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Custom Navigation Bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                        .padding(.leading, 16)
                }
                
                Text("Hashtag Collection")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
            }
            .padding(.top, UIApplication.shared.safeAreaTop)
            .padding(.bottom, 10)
            .background(Color.clear)
            .zIndex(1)
            
            // Main Content
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: UIApplication.shared.safeAreaTop + 44)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Small Icon at Top - As per uploaded image
                        Image("hash_icon")
                            .resizable()
                            .frame(width: 94, height: 84)
                            .padding(.top, 30)
                        
                        // Title and Subtitle Labels
                        VStack(spacing: 12) {
                            Text("Add Hashtags to Your Post")
                                .font(.custom("Poppins-Black", size: 22))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("Add relevant hashtags to boost visibility and engagement.")
                                .font(.custom("Urbanist-Medium", size: 16))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 30)
                        }
                        
                        // Large Icon
                        Image("addHashTag_ic")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: UIDevice.current.userInterfaceIdiom == .pad ? 233 : 213,
                                height: UIDevice.current.userInterfaceIdiom == .pad ? 234 : 223
                            )
                            .padding(.top, 10)
                        
                        Spacer(minLength: 30)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                }
                
                // Add Hashtags Button - Fixed at bottom with full width
                Button(action: {
                    showAddHashtagSheet = true
                }) {
                    Text("Add Hashtages")
                        .font(.custom("Urbanist-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#1973E8"),
                                    Color(hex: "#0E4082")
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: Color(hex: "#1973E8").opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.all, edges: .top)
        .sheet(isPresented: $showAddHashtagSheet) {
            AddHashtagSheetView(hashtagText: $hashtagText)
                .presentationDetents([.height(450)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.clear)
        }
    }
}

// Bottom Sheet View for Adding Hashtags
struct AddHashtagSheetView: View {
    @Binding var hashtagText: String
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTextViewFocused: Bool
    
    var body: some View {
        ZStack {
            // Linear Gradient Background - #471428 to #111637
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#471428"),
                    Color(hex: "#111637")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                // Title Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Hashtags")
                        .font(.custom("Poppins-Black", size: 22))
                        .foregroundColor(.white)
                    
                    Text("Choose the right hashtags for better engagement.")
                        .font(.custom("Urbanist-Medium", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Text View with Dotted Border - Removed fixed height
                ZStack(alignment: .topLeading) {
                    // Background with gradient
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.05),
                                    Color.white.opacity(0.15)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Dotted border overlay
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .foregroundColor(Color.white.opacity(0.3))
                    
                    // TextEditor with placeholder
                    ZStack(alignment: .topLeading) {
                        if hashtagText.isEmpty && !isTextViewFocused {
                            Text("Write here...")
                                .font(.custom("Urbanist-Regular", size: 16))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                        }
                        
                        TextEditor(text: $hashtagText)
                            .font(.custom("Urbanist-Regular", size: 16))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 150, maxHeight: .infinity) // Flexible height
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .focused($isTextViewFocused)
                    }
                }
                .frame(maxHeight: .infinity) // Takes available space
                .padding(.horizontal, 20)
                .padding(.top, 25) // Top spacing from subtitle (25)
                .padding(.bottom, 25) // Bottom spacing to buttons (25)
                
                // Buttons Section
                HStack(spacing: 12) {
                    // Cancel Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#1973E8"),
                                        Color(hex: "#0E4082")
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(26)
                            .overlay(
                                RoundedRectangle(cornerRadius: 26)
                                    .stroke(Color(hex: "#1973E8"), lineWidth: 1)
                            )
                            .shadow(color: Color(hex: "#3F5EFB").opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    
                    // Done Button
                    Button(action: {
                        // Handle done action - save hashtags
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#1973E8"),
                                        Color(hex: "#0E4082")
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(26)
                            .shadow(color: Color(hex: "#3F5EFB").opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 0) // Changed from 30 to 40
            }
        }
        .onAppear {
            // Fix for TextEditor background
            UITextView.appearance().backgroundColor = .clear
        }
    }
}
#Preview {
    AddHashTagView()
}

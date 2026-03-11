//
//  CaptionBoxView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 11/03/26.
//

import SwiftUI

struct CaptionBoxView: View {
    @ObservedObject var viewModel = CategoryViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
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
                
                Spacer()
                
                Text("Happiness Caption Box")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty view for balance
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 47)
            .padding(.bottom, 10)
            .background(Color.clear)
            .zIndex(1)
            
            // Content starts from top (below custom nav bar)
            VStack(spacing: 0) {
                // Spacer for custom nav bar height
                Color.clear
                    .frame(height: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 47) + 44)
                
                ScrollView {
                    LazyVStack(spacing: 12) { // Minimal spacing between cards
                        ForEach(viewModel.categories.indices, id: \.self) { index in
                            CaptionBoxCardView(
                                index: index + 1,
                                title: viewModel.categories[index].category_name
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 8) // Small top padding after nav bar
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true) // Hide default navigation bar
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar) // Hide tab bar
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            // Ensure tab bar is hidden when this view appears
            hideTabBar()
        }
    }
    
    private func hideTabBar() {
        // This will help ensure tab bar is hidden
        NotificationCenter.default.post(name: NSNotification.Name("HideTabBar"), object: nil)
    }
}

struct CaptionBoxCardView: View {
    var index: Int
    var title: String
    
    var body: some View {
        HStack {
            Text("\(index).    \(title)")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
            Spacer()
            Image("rightArrow")
                .resizable()
                .frame(width: 10, height: 16)
        }
        .padding(.horizontal, 15)
        .frame(height: 52) // Reduced height for tighter spacing
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#541834"), Color(hex: "#302555")]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16)
    }
}

#Preview {
    CaptionBoxView()
}

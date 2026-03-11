//
//  CaptionBoxView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 11/03/26.
//

import SwiftUI

struct CaptionBoxView: View {
    @ObservedObject var viewModel = CategoryViewModel()
    
    var body: some View {
        ZStack {
            Image("app_bg_image")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Content starts from safe area top
                ScrollView {
                    LazyVStack(spacing: 8) { // Reduced spacing between cards to 8
                        ForEach(viewModel.categories.indices, id: \.self) { index in
                            CaptionBoxCardView(
                                index: index + 1,
                                title: viewModel.categories[index].category_name
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 16) // Small top padding from safe area
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar) // Hide navigation bar background
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Caption Box")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
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
        .frame(height: 60)
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

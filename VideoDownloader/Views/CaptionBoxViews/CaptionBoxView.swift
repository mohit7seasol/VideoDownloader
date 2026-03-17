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
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
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
                
                Text("Caption Box".localized(language))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                Spacer()
                
                // Empty view for balance
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.top, UIApplication.shared.safeAreaTop)
            .padding(.bottom, 10)
            .background(Color.clear)
            .zIndex(1)
            
            // Content starts from top (below custom nav bar)
            VStack(spacing: 0) {
                // Spacer for custom nav bar height
                Color.clear
                    .frame(height: UIApplication.shared.safeAreaTop + 44)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.categories.indices, id: \.self) { index in
                            CaptionBoxCardView(
                                viewModel: viewModel, 
                                index: index + 1,
                                title: viewModel.categories[index].category_name,
                                categoryId: viewModel.categories[index].id
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            hideTabBar()
        }
    }
    
    private func hideTabBar() {
        NotificationCenter.default.post(name: NSNotification.Name("HideTabBar"), object: nil)
    }
}

struct CaptionBoxCardView: View {
    @ObservedObject var viewModel: CategoryViewModel
    var index: Int
    var title: String
    var categoryId: Int
    
    var body: some View {
        NavigationLink(destination: CaptionContentView(
            viewModel: viewModel,
            selectedCategoryId: categoryId,
            categoryTitle: title
        )) {
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
            .frame(height: 52)
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
}

#Preview {
    CaptionBoxView()
}

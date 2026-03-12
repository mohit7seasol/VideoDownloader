//
//  HashTagCategoriesView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 12/03/26.
//

import SwiftUI

struct HashTagCategoriesView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let category = [
        "Animals","Architecture","Celebrities","Eid","Family","Fashion","Follow",
        "Food","Holidays","Instagram","Nature","People","Photography",
        "Sports","Text","Tiktok","Travel","Weather"
    ]
    
    var columns: [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
        } else {
            return Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
        }
    }
    
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
                
                Text("Hashtag Collection")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                
                Spacer()
                
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.top, UIApplication.shared.safeAreaTop)
            .padding(.bottom, 10)
            .zIndex(1)
    
            VStack(spacing: 0) {
                
                Color.clear
                    .frame(height: UIApplication.shared.safeAreaTop + 44)
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 20) {
                        
                        HashTagBannerView()
                        
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(category, id: \.self) { item in
                                HashTagCategoryCard(name: item)
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .padding(.bottom, 25)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
struct HashTagBannerView: View {
    
    var bannerHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 130 : 114
    }
    
    var body: some View {
        
        ZStack {
            
            Image("hashTagBanner")
                .resizable()
                .scaledToFill()
            
            HStack(spacing: 12) {
                
                Image("hash_icon")
                    .resizable()
                    .frame(width: 74, height: 72)
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text("Add Hashtags")
                        .font(.custom("Poppins-Black", size: 22))
                        .foregroundColor(.white)
                    
                    Text("Choose the right hashtags for better engagement.")
                        .font(.custom("Urbanist-Medium", size: 14))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 18)
        }
        .frame(height: bannerHeight)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
struct HashTagCategoryCard: View {
    
    let name: String
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
            
            // Icon (fixed top-left)
            Image(name.lowercased())
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(.leading, 10)
                .padding(.top, 10)
            
            // Bottom label
            VStack {
                Spacer()
                
                HStack {
                    Text(name)
                        .font(.custom("Urbanist-Medium", size: 15))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
        }
        .frame(height: 110)
    }
}
#Preview {
    HashTagCategoriesView()
}

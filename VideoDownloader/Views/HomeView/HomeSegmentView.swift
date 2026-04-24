//
//  HomeSegmentView.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 17/04/26.
//

import SwiftUI

struct HomeSegmentView: View {
    
    @State private var selectedIndex: Int = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            
            // MARK: Content Switching
            Group {
                if selectedIndex == 0 {
                    HomeView()
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true)
                } else {
                    SavedAssetsView()
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true)
                }
            }
            .ignoresSafeArea()
            
            // MARK: Bottom Segment
            VStack {
                Spacer()
                
                CustomSegmentBar(selectedIndex: $selectedIndex)
                    .padding(.bottom, Device.bottomSafeArea)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Hide the navigation bar when this view appears
            setupNavigationBar()
        }
    }
    
    private func setupNavigationBar() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().isTranslucent = true
    }
}

// MARK: - CustomSegmentBar
struct CustomSegmentBar: View {
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    @Binding var selectedIndex: Int
    
    var body: some View {
        HStack(spacing: 6) {
            
            segmentItem(
                index: 0,
                title: "Home".localized(language),
                selectedIcon: "home_selected_ic",
                unselectedIcon: "home_unselected_ic"
            )
            
            segmentItem(
                index: 1,
                title: "Save".localized(language),
                selectedIcon: "save_seg_selected_ic",
                unselectedIcon: "save_seg_unselected_ic"
            )
        }
        .padding(6)
        .frame(height: Device.isIpad ? 65 : 60)
        .background(
            Group {
                if AppVersion.isIOS26 {
                    Capsule()
                        .fill(.ultraThinMaterial)
                } else {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .background(.ultraThinMaterial)
                }
            }
        )
        .modifier(GlassCardModifier(cornerRadius: 25))
        .clipShape(Capsule())
        .padding(.horizontal, 25)
    }
    
    // MARK: Segment Item
    func segmentItem(index: Int, title: String, selectedIcon: String, unselectedIcon: String) -> some View {
        
        let isSelected = selectedIndex == index
        
        return Button {
            withAnimation(.easeInOut) {
                selectedIndex = index
            }
        } label: {
            HStack(spacing: 8) {
                
                Image(isSelected ? selectedIcon : unselectedIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Device.isIpad ? 20 : 18, height: Device.isIpad ? 20 : 18)
                
                Text(title)
                    .font(.system(size: Device.isIpad ? 20 :14, weight: .medium))
                    .foregroundColor(
                        isSelected ? .white.opacity(0.9) : Color(hex: "#A2A2A2")
                    )
            }
            .frame(maxWidth: .infinity)
            .frame(height: Device.isIpad ? 53 : 48)
            .background(
                ZStack {
                    
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FC466B"),
                                        Color(hex: "#3F5EFB")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    } else {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#2F2A2A"),
                                        Color(hex: "#1B1516")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                    }
                }
            )
        }
    }
}

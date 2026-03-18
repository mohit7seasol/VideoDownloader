//
//  SettingView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 11/03/26.
//

import SwiftUI

struct SettingView: View {
    @State private var isShowingLanguageView = false
    @Environment(\.dismiss) var dismiss
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background Image
            Image("app_bg_image")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Custom Navigation Bar (exactly like AddHashTagView)
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                        .padding(.leading, 16)
                }
                
                Text("Settings".localized(self.language))
                    .font(.custom("Urbanist-Medium", size: 20))
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
                    VStack(spacing: 20) {
                        // Premium Top View
                        /* PremiumTopView() */ // Hide for first version
                        
                        // Bottom Setting Card
                        BottomSettingCard(
                            isShowingLanguageView: $isShowingLanguageView,
                            privacyPolicy: privacyPolicy,
                            termsOfUse: termsOfUse,
                            eula: eula,
                            reviewLink: REVIEW_LINK,
                            shareApp: shareApp,
                            appID: APP_ID
                        )
                    }
                    .padding(.horizontal, 15)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.all, edges: .top)
        .background(
            NavigationLink(
                destination: LanguageView(isOpenFromSetting: true)
                    .navigationBarHidden(true) 
                    .navigationBarBackButtonHidden(true),
                isActive: $isShowingLanguageView
            ) {
                EmptyView()
            }
        )
    }
}

struct PremiumTopView: View {
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    var body: some View {
        ZStack {
            
            Image("premiumTopBg")
                .resizable()
                .scaledToFill()
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Join Full Experience".localized(self.language))
                    .font(.custom("Urbanist-Medium", size: 16))
                    .foregroundColor(.white)
                    .padding(.top, 30)   // ✅ Top space 15
                
                Text("Upgrade".localized(self.language))
                    .font(.custom("Unlock-Regular", size: 28))
                    .foregroundColor(.white)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    FeatureRow(text: "Ad-free experience".localized(self.language))
                    FeatureRow(text: "Saved All Video Links".localized(self.language))
                    FeatureRow(text: "Edit Photos & Videos".localized(self.language))
                    FeatureRow(text: "Enhance Videos with Music".localized(self.language))
                    
                }
                .padding(.top, 16)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        
                        Text("Get Upgrade".localized(self.language))
                            .font(.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(width: 170, height: 50)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#1973E8"), Color(hex: "#0E4082")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                    }
                    
                    Spacer()
                }
                .padding(.top, 20)
                
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
        }
        .frame(height: 260)
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image("premium_features")
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundColor(.white)
            
            Text(text)
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
        }
    }
}

struct BottomSettingCard: View {
    @Binding var isShowingLanguageView: Bool
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    let privacyPolicy: String
    let termsOfUse: String
    let eula: String
    let reviewLink: String
    let shareApp: String
    let appID: String
    
    let settingsItems: [(icon: String, title: String)] = [
        ("language", "Language"),
        ("rate app", "Rate App"),
        ("share app", "Share App"),
        ("privacy policy", "Privacy Policy"),
        ("terms", "Terms")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(settingsItems.enumerated()), id: \.offset) { index, item in
                VStack(spacing: 0) {
                    // Moved onTapGesture from SettingRow to here
                    SettingRow(icon: item.icon, title: item.title.localized(self.language))
                        .contentShape(Rectangle()) // Makes entire area tappable
                        .onTapGesture {
                            handleTap(for: item.title)
                        }
                    
                    // Add line separator only if not the last item
                    if index < settingsItems.count - 1 {
                        Image("line_ic")
                            .resizable()
                            .frame(height: 1)
                            .padding(.leading, 0) 
                            .padding(.trailing, 0)
                    }
                }
            }
        }
        .padding(.horizontal, 15)
        .background(Color.clear)
    }
    
    func handleTap(for title: String) {
        switch title {
        case "Language":
            isShowingLanguageView = true
        case "Rate App":
            if let url = URL(string: reviewLink) {
                UIApplication.shared.open(url)
            }
        case "Share App":
            let shareText = "\("Check out this app!".localized(self.language)) \(shareApp)"
            let activityVC = UIActivityViewController(
                activityItems: [shareText],
                applicationActivities: nil
            )
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        case "Privacy Policy":
            if let url = URL(string: privacyPolicy) {
                UIApplication.shared.open(url)
            }
        case "Terms":
            if let url = URL(string: termsOfUse) {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
    }
}
struct SettingRow: View {
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(icon)
                .resizable()
                .frame(width: 40, height: 40)
            
            Text(title.localized(self.language))
                .font(.custom("Urbanist-Medium", size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Image("right_arrow")
                .resizable()
                .frame(width: 7, height: 12)
                .opacity(0.7)
        }
        .padding(.vertical, 16)
    }
}
// MARK: - Preview
struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

//
//  LanguageView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import Foundation
import SwiftUI
import Lottie

struct LanguageView: View {

    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(SessionKeys.isLanguageDone) var isLanguageDone = false
    @StateObject var vm = LanguageViewModel()
    var isOpenFromSetting: Bool = false
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: isIpad ? 4 : 2)
    }

    var body: some View {

        ZStack {

            Image("app_bg_image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // ✅ شرط: Show navbar only if opened from settings
                if isOpenFromSetting {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .medium))
                                .padding(.leading, 16)
                        }

                        Text("".localized(self.language))
                            .font(.custom("Urbanist-Medium", size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10)
                    }
                    .padding(.top, UIApplication.shared.safeAreaTop)
                    .padding(.bottom, 10)
                    .zIndex(1)
                }

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {

                        Text("Instant Video Download".localized(self.language))
                            .font(Font.custom("Unlock-Regular", size: 22))
                            .foregroundColor(.white)

                        Text("Paste the link and enjoy fast, hassle-free video downloads".localized(self.language))
                            .font(Font.custom("Urbanist-Medium", size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, isOpenFromSetting ? 20 : 48) // ✅ adjust spacing

                    // MARK: Language Grid
                    ScrollView(showsIndicators: false) {

                        LazyVGrid(columns: columns, spacing: 16) {

                            ForEach(languages, id: \.languageCode) { item in

                                LanguageRow(
                                    item: item,
                                    isSelected: vm.selectedLanguage == item.languageCode
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        vm.selectedLanguage = item.languageCode
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 25)
                        .padding(.bottom, 120)
                    }

                    Spacer()
                }
            }

            // Bottom button (unchanged)
            VStack {
                Spacer()

                ZStack {
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0),
                            Color.black.opacity(0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 140)
                    .ignoresSafeArea(edges: .bottom)

                    Button {
                        language = vm.selectedLanguage ?? .English

                        if !isLanguageDone {
                            isLanguageDone = true
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }

                    } label: {
                        Text("Done".localized(self.language))
                            .font(Font.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 34)
                }
            }
        }
        .onAppear {
            vm.selectedLanguage = language
        }
    }
}
struct LanguageRow: View {

    let item: AppLanguage
    let isSelected: Bool

    private var bgColor: Color {
        Color(item.englishName.lowercased())
    }

    var body: some View {

        ZStack(alignment: .topLeading) {

            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [
                            bgColor.opacity(0.20),
                            bgColor.opacity(0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    bgColor.opacity(0.40),
                                    bgColor.opacity(0.10)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )

            VStack {

                HStack {

                    // Selected icon (top-left)
                    if isSelected {
                        Image("selected_language")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 42, height: 42)
                    }

                    Spacer()

                    // Language flag (top-right)
                    item.image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()

                // Bottom-left labels
                VStack(alignment: .leading, spacing: 4) {

                    Text(item.englishName)
                        .font(Font.custom("Urbanist-Regular", size: 18))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(item.LocalName)
                        .font(Font.custom("Urbanist-Regular", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
        .frame(height: 140)
    }
}
#Preview {
    LanguageView()
}

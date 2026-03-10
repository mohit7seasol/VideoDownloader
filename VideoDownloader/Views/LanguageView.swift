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
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var cellHeight: CGFloat {
        isIpad ? 100 : 60
    }
    
    private var iconSize: CGFloat {
        isIpad ? 60 : 40
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#0B0C1E")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: Top Section
                HStack(alignment: .top) {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        
                        Text("Choose Language".localized(language))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("\("Select your preferred app".localized(language))\n\("language".localized(language))")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#9398C8"))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    MyLottieView(animationFileName: "translation",
                                 loopMode: .loop)
                        .frame(width: 132, height: 132)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // MARK: Continue Button
                Button {
                    language = vm.selectedLanguage ?? .English
                    if !isLanguageDone {
                        isLanguageDone = true
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    if #available(iOS 26.0, *) {
                        Text("Continue".localized(language))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                Color(hex: "#5A5ED9")
                                    .opacity(0.3)
                            )
                            .clipShape(Capsule())
                            .glassEffect()
                    } else {
                        // Fallback on earlier versions
                        Text("Continue".localized(language))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                Color(hex: "#5A5ED9")
                                    .opacity(0.3)
                            )
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, -50)
                
                // MARK: Language List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        ForEach(languages, id: \.languageCode) { item in
                            
                            LanguageRow(
                                item: item,
                                isSelected: vm.selectedLanguage == item.languageCode,
                                cellHeight: cellHeight,
                                iconSize: iconSize
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    vm.selectedLanguage = item.languageCode
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 15) // 15 left & right
                    .padding(.top, 25)
                    .padding(.bottom, 40)
                }
                .padding(.top, 4)
            }
        }
        .onAppear {
            vm.selectedLanguage = language
        }
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarColorScheme(.none, for: .navigationBar)
    }
}
struct LanguageRow: View {
    
    let item: AppLanguage
    let isSelected: Bool
    let cellHeight: CGFloat
    let iconSize: CGFloat
    
    private var styledLanguageText: AttributedString {
        var english = AttributedString(item.englishName)
        english.foregroundColor = .white
        english.font = .systemFont(ofSize: 16, weight: .medium)
        
        var local = AttributedString(" (\(item.LocalName))")
        local.foregroundColor = UIColor(Color(hex: "#717186"))
        local.font = .systemFont(ofSize: 16, weight: .medium)
        
        return english + local
    }
    
    var body: some View {
        HStack(spacing: 15) {
            
            item.image
                .resizable()
                .scaledToFill()
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(styledLanguageText)
            
            Spacer()
            
            if isSelected {
                Image("selected_language")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 14)
            }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: cellHeight)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.black.opacity(0.45))
                
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
}

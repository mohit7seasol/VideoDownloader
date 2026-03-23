//
//  HomeView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import SwiftUI
import Lottie

struct HomeItem {
    let title: String
    let subtitle: String
    let icon: String
    let bgColor: String
}

let homeItems: [HomeItem] = [

    HomeItem(
        title: "Caption Box",
        subtitle: "Express your moment in words",
        icon: "h1",
        bgColor: "#A925CA"
    ),

    HomeItem(
        title: "Hashtag Collection",
        subtitle: "Quick access to top hashtags",
        icon: "h2",
        bgColor: "#6D41F5"
    ),

    HomeItem(
        title: "Soundtrack",
        subtitle: "Enhance your video with music and audio.",
        icon: "h4",
        bgColor: "#088589"
    ),

    HomeItem(
        title: "Image Editor",
        subtitle: "Edit photos with powerful and easy tools",
        icon: "h5",
        bgColor: "#104AD5"
    )
]

struct HomeView: View {
    private var isIpad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    }
    @State private var navigateToSomeView = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("app_bg_image")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    TopHomeView()
                    
                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(homeItems.indices, id: \.self) { index in
                            HomeViewCard(item: homeItems[index])
                        }
                    }
                    .padding(.horizontal, 20)
//                    ThirdCardView()
                    Spacer()
                }
                .padding(.top, UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first?.windows
                    .first?.safeAreaInsets.top ?? 0)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .hideNavigationbar() // ✅ Use your extension
        .navigationDestination(isPresented: $navigateToSomeView) {
            SettingView()
        }
    }
}
struct TopHomeView: View {
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        
        HStack {
            
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(
                    width: isIpad ? 140 : 120,
                    height: isIpad ? 42 : 32
                )
            
            Spacer()
            
            NavigationLink(destination: SettingView()) {
                Image("setting_ic")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: isIpad ? 36 : 26,
                        height: isIpad ? 36 : 26
                    )
                    .padding(.trailing, 5)
            }
        }
        .padding(.horizontal, 20)
    }
}
struct HomeViewCard: View {
    let item: HomeItem
    @State private var navigateToDestination = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language

    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // CARD
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: item.bgColor).opacity(0.10),
                            Color(hex: item.bgColor).opacity(0.70)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 10) {
                Spacer().frame(height: 14)

                // Title
                Text(item.title.localized(self.language))
                    .font(Font.custom("Urbanist-Bold", size: 16))
                    .foregroundColor(.white)

                // Subtitle
                Text(item.subtitle.localized(self.language))
                    .font(Font.custom("Urbanist-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                // Navigation button
                Button(action: {
                    navigateToDestination = true
                }) {
                    buttonLabel
                }

                Spacer(minLength: 40)
            }

            // ICON
            Image(item.icon)
                .resizable()
                .scaledToFit()
                .frame(height: isIpad ? 100 : 86)
                .padding(.horizontal, 30)
                .offset(y: 18)
        }
        .frame(height: isIpad ? 270 : 220)
        .clipped(antialiased: false)
        .background(
            NavigationLink(
                destination: destinationView,
                isActive: $navigateToDestination,
                label: { EmptyView() }
            )
            .hidden()
        )
    }

    @ViewBuilder
    private var destinationView: some View {
        switch item.title {
        case "Caption Box":
            CaptionBoxView()
        case "Hashtag Collection":
            HashTagCategoriesView()
        case "Soundtrack":
            SoundTrackView()
        case "Image Editor":
            PhotoChooseView()
        default:
            EmptyView()
        }
    }

    private var buttonLabel: some View {
        Text("View More".localized(self.language))
            .font(Font.custom("Urbanist-Bold", size: 12))
            .foregroundColor(Color(hex: "#0D1426"))
            .frame(
                width: isIpad ? 110 : 90,
                height: isIpad ? 42 : 30
            )
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(
                color: Color(hex: "#0D1426").opacity(0.4),
                radius: 6,
                x: 0,
                y: 4
            )
    }
}

struct ThirdCardView: View {
    
    @State private var navigate = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#088589").opacity(0.10),
                            Color(hex: "#088589").opacity(0.70)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            HStack {
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Spacer().frame(height: 14)
                    
                    Text("Soundtrack".localized(language))
                        .font(Font.custom("Urbanist-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Text("Enhance your video with music and audio.".localized(language))
                        .font(Font.custom("Urbanist-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(3)
                    
                    Button {
                        navigate = true
                    } label: {
                        Text("View More".localized(language))
                            .font(Font.custom("Urbanist-Bold", size: 12))
                            .foregroundColor(Color(hex: "#0D1426"))
                            .frame(
                                width: isIpad ? 110 : 90,
                                height: isIpad ? 42 : 30
                            )
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(
                                color: Color(hex: "#0D1426").opacity(0.4),
                                radius: 6,
                                x: 0,
                                y: 4
                            )
                    }
                    
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.trailing, 10)
                
                Spacer()
                
                Image("h4")
                    .resizable()
                    .scaledToFit()
                    .frame(height: isIpad ? 100 : 86)
                    .padding(.trailing, 15)
            }
        }
        .frame(height: isIpad ? 180 : 140)
        .padding(.horizontal, 20)
        .navigationDestination(isPresented: $navigate) {
            SoundTrackView()
        }
    }
}
#Preview {
    HomeView()
}


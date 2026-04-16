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
        if Device.isIpad {
            GeometryReader { geometry in
                ZStack {
                    Image("app_bg_image")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            TopHomeView()
                                .padding(.top, UIApplication.shared.connectedScenes
                                    .compactMap { $0 as? UIWindowScene }
                                    .first?.windows
                                    .first?.safeAreaInsets.top ?? 0)
                            
                            // Grid Cards
                            LazyVGrid(columns: columns, spacing: 18) {
                                ForEach(homeItems.indices, id: \.self) { index in
                                    HomeViewCard(item: homeItems[index])
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // ✅ Bottom Features for iPad
                            BottomFeaturesView()
                            
                            // Extra bottom space
                            Spacer()
                                .frame(height: 600)
                        }
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .hideNavigationbar()
            .navigationDestination(isPresented: $navigateToSomeView) {
                SettingView()
            }
        } else {
            ZStack {
                Image("app_bg_image")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // ✅ FIXED HEADER (NON-SCROLL)
                    TopHomeView()
                        .padding(.top, UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .first?.windows
                            .first?.safeAreaInsets.top ?? 0)
                    
                    // ✅ SCROLLABLE CONTENT
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            
                            LazyVGrid(columns: columns, spacing: 18) {
                                ForEach(homeItems.indices, id: \.self) { index in
                                    HomeViewCard(item: homeItems[index])
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            BottomFeaturesView()
                            
                            // ✅ EXTRA BOTTOM SPACE (IMPORTANT FIX)
                            Spacer()
                                .frame(height: 50)
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .hideNavigationbar()
            .navigationDestination(isPresented: $navigateToSomeView) {
                SettingView()
            }
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
                    width: isIpad ? 200 : 120,
                    height: isIpad ? 42 : 32
                )
            
            Spacer()
            
            NavigationLink(destination: SettingView()) {
                Image("setting_ic")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: isIpad ? 30 : 26,
                        height: isIpad ? 30 : 26
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
                Spacer().frame(height: Device.isIpad ? 22 : 14)

                // Title
                Text(item.title.localized(self.language))
                    .font(Font.custom("Urbanist-Bold", size: Device.isIpad ? 24 : 16))
                    .foregroundColor(.white)

                // Subtitle
                Text(item.subtitle.localized(self.language))
                    .font(Font.custom("Urbanist-Regular", size: Device.isIpad ? 20 : 12))
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
                .frame(height: isIpad ? 120 : 86)
                .padding(.horizontal, 30)
                .offset(y: 18)
        }
        .frame(height: isIpad ? 350 : 220)
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
            PhotoChooseView(selectionType: .photoEdit)
        default:
            EmptyView()
        }
    }

    private var buttonLabel: some View {
        Text("View More".localized(self.language))
            .font(Font.custom("Urbanist-Bold", size: Device.isIpad ? 20 : 12))
            .foregroundColor(Color(hex: "#0D1426"))
            .frame(
                width: isIpad ? 150 : 90,
                height: isIpad ? 62 : 30
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
// MARK: - Bottom Features View
struct BottomFeaturesView: View {
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // TITLE
            Text("Edit Photos Like a Pro")
                .font(.custom("Poppins-Black", size: 20))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                
                BottomFeaturesCardView(
                    bgImage: "e_ic",
                    title: "Photo Collage Maker",
                    icon: "pencil_ic",
                    buttonColor: "#FFCC3F"
                )
                
                BottomFeaturesCardView(
                    bgImage: "s_ic",
                    title: "Smart Background Editor",
                    icon: "gallery_ic",
                    buttonColor: "#45B8FF"
                )
            }
        }
    }
}

//
// MARK: - Bottom Feature Card
//
struct BottomFeaturesCardView: View {
    
    let bgImage: String
    let title: String
    let icon: String
    let buttonColor: String
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    @State private var navigateToPhotoPicker = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // BACKGROUND IMAGE
            Image(bgImage)
                .resizable()
                .scaledToFill()
                .frame(height: isIpad ? 180 : 150)
                .clipped()
                .cornerRadius(16)
            
            // OVERLAY
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.6)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(16)
            
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                        Text(title)
                            .font(.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button {
                        navigateToPhotoPicker = true
                    } label: {
                        Text("Try Now")
                            .font(.custom("Urbanist-Bold", size: 14))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(hex: buttonColor))
                            .cornerRadius(12)
                    }
                }
                .padding(16)
            }
            
            // Navigation based on title
            NavigationLink(
                destination: destinationView,
                isActive: $navigateToPhotoPicker
            ) {
                EmptyView()
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if title == "Smart Background Editor" {
            PhotoChooseView(selectionType: .photoBGRemover)
        } else if title == "Photo Collage Maker" {
            CollageMakerView() 
        }
    }
}
#Preview {
    HomeView()
}


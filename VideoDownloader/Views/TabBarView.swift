//
//  TabBarView.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import SwiftUI
import Lottie

struct TabBarView: View {
    
    @StateObject private var tabManager = TabSelectionManager()
    
    var body: some View {
        ZStack {
            
            // MARK: Screens
            Group {
                switch tabManager.selectedTab {
                case 0:
                    HomeView()
                        .environmentObject(tabManager)
                case 1:
                    LinkView()
                        .environmentObject(tabManager)
                case 2:
                    SavedVideoView()
                        .environmentObject(tabManager)
                default:
                    LinkView()
                        .environmentObject(tabManager)
                }
            }
            
            VStack {
                Spacer()
                CustomTabBar(selectedIndex: $tabManager.selectedTab)
            }
        }
        .ignoresSafeArea()
    }
}


// MARK: - Custom Tabbar
struct CustomTabBar: View {
    
    @Binding var selectedIndex: Int
    
    var body: some View {
        
        ZStack {
            
            // Background
            TabBarCurve()
                .fill(
                    LinearGradient(
                        colors: [
                            Color("TabbarGradient1"),
                            Color("TabbarGradient2")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 95)
                .ignoresSafeArea()
            
            // Left + Right Tabs
            HStack {
                
                // Home
                Button {
                    selectedIndex = 0
                } label: {
                    VStack(spacing: 4) {
                        
                        Image(selectedIndex == 0 ? "home_selected" : "home_unselected")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22,height: 22)
                        
                        Text("Home")
                            .font(.caption2)
                            .foregroundColor(
                                selectedIndex == 0
                                ? Color(red: 25/255, green: 115/255, blue: 232/255)
                                : .white
                            )
                    }
                }
                
                Spacer()
                
                // Save
                Button {
                    selectedIndex = 2
                } label: {
                    VStack(spacing: 4) {
                        
                        Image(selectedIndex == 2 ? "save_selected" : "save_unselected")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22,height: 22)
                        
                        Text("Save")
                            .font(.caption2)
                            .foregroundColor(
                                selectedIndex == 2
                                ? Color(red: 25/255, green: 115/255, blue: 232/255)
                                : .white
                            )
                    }
                }
            }
            .padding(.horizontal, 60)
            .padding(.bottom, 20)
            .frame(height: 95)
            
            // Center Button
            Button {
                selectedIndex = 1
            } label: {
                
                ZStack {
                    
                    Image("link_bg")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 65, height: 65)
                        .clipShape(Circle())
                        .shadow(radius: 6)
                    
                    LottieView(name: "Link")
                        .frame(width: 40, height: 40)
                }
            }
            .offset(y: -42)
        }
    }
}

struct TabBarCurve: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        let center = rect.width / 2
        
        return Path { path in
            
            path.move(to: CGPoint(x: 0, y: 0))
            
            path.addLine(to: CGPoint(x: center - 80, y: 0))
            
            path.addCurve(
                to: CGPoint(x: center, y: 45),
                control1: CGPoint(x: center - 40, y: 0),
                control2: CGPoint(x: center - 35, y: 45)
            )
            
            path.addCurve(
                to: CGPoint(x: center + 80, y: 0),
                control1: CGPoint(x: center + 35, y: 45),
                control2: CGPoint(x: center + 40, y: 0)
            )
            
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
    }
}

// MARK: - Lottie View
struct LottieView: UIViewRepresentable {
    
    var name: String
    
    func makeUIView(context: Context) -> UIView {
        
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = .loop
        animationView.play()
        animationView.contentMode = .scaleAspectFit
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    TabBarView()
}

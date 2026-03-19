//
//  TabSelectionManager.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 16/03/26.
//

import SwiftUI
import Combine

class TabSelectionManager: ObservableObject {
    @Published var selectedTab: Int = 0 // Changed default to HomeView (index 0)
    
    func navigateToHistory() {
        selectedTab = 2
    }
}

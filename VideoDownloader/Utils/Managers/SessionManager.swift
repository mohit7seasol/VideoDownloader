//
//  SessionManager.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 09/03/26.
//

import Foundation
import SwiftUI

struct SessionManagerKeys {
    static var favKey = "favKey"
    static var browserKeys = "browserKeys"
    static var quality = "quality"
    static let favMovies = "fav_movies"

}

class SessionManager {
    static let shared = SessionManager()
    
    private init() {}
    
    func saveFavorites(_ ids: [String]) {
        UserDefaults.standard.set(ids, forKey: SessionManagerKeys.favKey)
    }
    
    func getFavorites() -> [String] {
        return UserDefaults.standard.stringArray(forKey: SessionManagerKeys.favKey) ?? []
    }
}

extension SessionManager {
    
//    func setSplashData(datum: SettingModel) {
//        do {
//            let data = try JSONEncoder().encode(datum)
//            UserDefaults.standard.set(data, forKey: "splash_data")
//            UserDefaults.standard.synchronize()
//        } catch let error {
//            print("❌ Error saving splash data:", error.localizedDescription)
//        }
//    }
//
//    func getSplashData() -> SettingModel? {
//        if let data = UserDefaults.standard.data(forKey: "splash_data") {
//            if let loaded = try? JSONDecoder().decode(SettingModel.self, from: data) {
//                return loaded
//            }
//        }
//        return nil
//    }
}

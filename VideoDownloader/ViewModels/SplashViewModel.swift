//
//  SplashViewModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import Foundation
import SwiftUI
import Combine

class SplashViewModel: ObservableObject {
    
    @Published var splashData: SettingModel?
    
    // MARK: - AppStorage properties for key values
    @AppStorage("bannerId") var bannerId: String = ""
    @AppStorage("nativeId") var nativeId: String = ""
    @AppStorage("interstialId") var interstialId: String = ""
    @AppStorage("appopenId") var appopenId: String = ""
    @AppStorage("smallNativeBannerId") var smallNativeBannerId: String = ""
    @AppStorage("addButtonColor") var addButtonColor: String = "#7462FF"
    @AppStorage("afterClick") var afterClick: Int = 4
    @AppStorage("customInterstial") var customInterstial: Int = 0
    
    // API Tokens
    @AppStorage("YoutubeAPIToken") var YoutubeAPIToken: String = ""
    @AppStorage("InstaAPIToken") var InstaAPIToken: String = ""
    @AppStorage("FacebookAPIToken") var FacebookAPIToken: String = ""
    @AppStorage("TiktokAPIToken") var TiktokAPIToken: String = ""
    
    // Media URL Flag
    @AppStorage("IsMediaURLOn") var IsMediaURLOn: String = ""
    
    func fetchSplashData(completion: (() -> Void)? = nil) {
        
        guard let url = URL(string: getJSON) else {
            print("❌ Invalid URL")
            DispatchQueue.main.async {
                completion?()
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                print("❌ Error:", error.localizedDescription)
                DispatchQueue.main.async {
                    completion?()
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion?()
                }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(SettingModel.self, from: data)
                
                DispatchQueue.main.async {
                    // Save the full decoded data
                    self.splashData = decoded
                    
                    // Save to UserDefaults using AppStorage (automatically saved)
                    self.bannerId = decoded.bannerID ?? ""
                    self.nativeId = decoded.nativeID ?? ""
                    self.interstialId = decoded.interstialID ?? ""
                    self.appopenId = decoded.appopenID ?? ""
                    self.addButtonColor = decoded.addButtonColor ?? "#7462FF"
                    self.afterClick = Int(decoded.afterClick ?? "4") ?? 4
                    self.customInterstial = Int(decoded.customInterstial ?? "0") ?? 0
                    
                    // Extra fields
                    self.smallNativeBannerId = decoded.extraFields?.smallNative ?? ""
                    self.YoutubeAPIToken = decoded.extraFields?.yov ?? ""
                    self.InstaAPIToken = decoded.extraFields?.inv ?? ""
                    self.FacebookAPIToken = decoded.extraFields?.fav ?? ""
                    self.TiktokAPIToken = decoded.extraFields?.tiv ?? ""
                    
                    #if DEBUG
                    self.IsMediaURLOn = decoded.extraFields?.play ?? "a"
                    #else
                    self.IsMediaURLOn = decoded.extraFields?.sub ?? ""
                    #endif
                    
                    print("✅ Successfully fetched and saved config data")
                    
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
                
            } catch {
                print("❌ JSON Decode Error:", error.localizedDescription)
                
                DispatchQueue.main.async {
                    completion?()
                }
            }
            
        }.resume()
    }
}

// MARK: - UserDefaults Extension for Encodable/Decodable
extension UserDefaults {
    func setEncodable<T: Encodable>(_ value: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            self.set(data, forKey: key)
        }
    }
    
    func getDecodable<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
}

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
    
    func fetchSplashData(completion: (() -> Void)? = nil) {
        
        guard let url = URL(string: getJSON) else {
            print("❌ Invalid URL")
            completion?()
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
                    self.splashData = decoded
                    completion?()
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

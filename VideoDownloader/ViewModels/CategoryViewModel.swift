//
//  CategoryViewModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 11/03/26.
//

import Foundation
import SwiftUI
import Combine

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var captionContents: [CaptionContent] = []
    
    init() {
        loadCategories()
        loadCaptionContents()
    }
    
    func loadCategories() {
        // Load categories from your categories.json or wherever you store them
        // This is just a placeholder - implement your actual category loading logic
        if let url = Bundle.main.url(forResource: "categories", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                self.categories = try decoder.decode([Category].self, from: data)
            } catch {
                print("Error loading categories: \(error)")
            }
        }
    }
    
    func loadCaptionContents() {
        // Load all contents from content.json
        if let url = Bundle.main.url(forResource: "contents", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                self.captionContents = try decoder.decode([CaptionContent].self, from: data)
                print("Successfully loaded \(self.captionContents.count) contents")
            } catch {
                print("Error loading content.json: \(error)")
            }
        } else {
            print("content.json file not found")
        }
    }
    
    // Helper method to get contents for a specific category
    func getContents(for categoryId: Int) -> [CaptionContent] {
        return captionContents.filter { $0.category_id == categoryId }
    }
}

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

    init() {
        loadCategories()
    }

    func loadCategories() {
        guard let url = Bundle.main.url(forResource: "categories", withExtension: "json") else {
            print("categories.json not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Category].self, from: data)
            DispatchQueue.main.async {
                self.categories = decoded
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
}

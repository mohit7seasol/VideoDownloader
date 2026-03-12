//
//  HashTagViewModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 12/03/26.
//

import SwiftUI
import Combine

class HashtagViewModel: ObservableObject {
    @Published var hashtagData: HashtagModel = HashtagModel()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchHashtags(for category: String) {
        guard let url = URL(string: "https://d2is1ss4hhk4uk.cloudfront.net/videodownload_hashtag.json") else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: HashtagModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { data in
                self.hashtagData = data
            })
            .store(in: &cancellables)
    }
    
    func getHashtagsForCategory(_ category: String) -> [HashtagModel.Hashtag] {
        guard let data = hashtagData.data else { return [] }
        
        // Find the category that matches (case insensitive)
        let matchedData = data.first { item in
            guard let itemName = item.name else { return false }
            return itemName.lowercased() == category.lowercased()
        }
        
        return matchedData?.hashtag ?? []
    }
}

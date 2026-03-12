//
//  CaptionContentModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 12/03/26.
//

struct CaptionContent: Identifiable, Codable {
    let category_id: Int
    let content: String
    let favorite: Int
    let id: Int
}

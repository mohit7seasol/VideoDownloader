//
//  HashtagModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 12/03/26.
//

import Foundation

struct HashtagModel: Codable {
    let data: [Data]?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    // Add explicit initializer for Codable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent([Data].self, forKey: .data)
    }
    
    // Add empty initializer for @Published property
    init() {
        self.data = []
    }
    
    struct Data: Codable {
        let id: Int?
        let name: String?
        let status: String?
        let hashtag: [Hashtag]?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case status = "status"
            case hashtag = "hashtag"
        }
        
        // Add initializer for Data struct
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decodeIfPresent(Int.self, forKey: .id)
            name = try container.decodeIfPresent(String.self, forKey: .name)
            status = try container.decodeIfPresent(String.self, forKey: .status)
            hashtag = try container.decodeIfPresent([Hashtag].self, forKey: .hashtag)
        }
        
        // Add empty initializer
        init() {
            self.id = nil
            self.name = nil
            self.status = nil
            self.hashtag = []
        }
    }
    
    struct Hashtag: Codable, Identifiable {
        let id: Int?
        let category: String?
        let tag_name: String?
        let tag_name_detail: String?
        let created_at: String?
        let updated_at: String?
        let deleted_at: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case category = "category"
            case tag_name = "tag_name"
            case tag_name_detail = "tag_name_detail"
            case created_at = "created_at"
            case updated_at = "updated_at"
            case deleted_at = "deleted_at"
        }
        
        // Add initializer for Hashtag struct
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decodeIfPresent(Int.self, forKey: .id)
            category = try container.decodeIfPresent(String.self, forKey: .category)
            tag_name = try container.decodeIfPresent(String.self, forKey: .tag_name)
            tag_name_detail = try container.decodeIfPresent(String.self, forKey: .tag_name_detail)
            created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
            updated_at = try container.decodeIfPresent(String.self, forKey: .updated_at)
            deleted_at = try container.decodeIfPresent(String.self, forKey: .deleted_at)
        }
        
        // Add empty initializer
        init() {
            self.id = nil
            self.category = nil
            self.tag_name = nil
            self.tag_name_detail = nil
            self.created_at = nil
            self.updated_at = nil
            self.deleted_at = nil
        }
    }
}

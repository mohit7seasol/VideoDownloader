//
//  LocalModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 09/03/26.
//

import Foundation
import SwiftUI

enum Language: String {
//    case Arabic = "ar"
    case English = "en"
    case Chinese = "zh-Hans"
    case Danish = "da"
    case Dutch = "nl"
    case French = "fr"
    case German = "de"
//    case Greek = "el"
    case Hindi = "hi"
//    case Indonesian = "id"
    case Italian = "it"
    case Japanese = "ja"
    case Korean = "ko"
//    case Norwegian = "no"
//    case Polish = "pl"
    case Portuguese = "pt-PT"
    case Russian = "ru"
    case Spanish = "es"
//    case Swedish = "sv"
//    case Thai = "th"
    case Turkish = "tr"
//    case Vietnamese = "vi"
}

extension String {
    func localized(_ language: Language) -> String {
        let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj")
        let bundle: Bundle
        if let path = path {
            bundle = Bundle(path: path) ?? .main
        } else {
            bundle = .main
        }
        return localized(bundle: bundle)
    }

    func localized(_ language: Language, args arguments: CVarArg...) -> String {
        let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj")
        let bundle: Bundle
        if let path = path {
            bundle = Bundle(path: path) ?? .main
        } else {
            bundle = .main
        }
        return String(format: localized(bundle: bundle), arguments: arguments)
    }

    private func localized(bundle: Bundle) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

class LocalizationService {
    
    static let shared = LocalizationService()
    static let changedLanguage = Notification.Name("changedLanguage")
    
    private init() {}
    
    var language: Language {
        get {
            guard let languageString = UserDefaults.standard.string(forKey: "language") else {
                                return Language(rawValue: String(Locale.preferredLanguages.first?.prefix(2) ?? "")) ?? .English
            }
            return Language(rawValue: languageString) ?? (Language(rawValue: String(Locale.preferredLanguages.first?.prefix(2) ?? "")) ?? .English)
        } set {
            if newValue != language {
                UserDefaults.standard.setValue(newValue.rawValue, forKey: "language")
                NotificationCenter.default.post(name: LocalizationService.changedLanguage, object: nil)
            }
        }
    }
}

struct AppLanguage {
    let id = UUID()
    let LocalName: String
    let image: Image
    let englishName: String
    let languageCode: Language
}

let languages = [
    AppLanguage(LocalName: "English", image: .uk, englishName: "English", languageCode: .English),
    AppLanguage(LocalName: "Deutsch", image: .german, englishName: "German", languageCode: .German),
    AppLanguage(LocalName: "हिंदी", image: .hindi, englishName: "Hindi", languageCode: .Hindi),
    AppLanguage(LocalName: "Italiana", image: .italy, englishName: "Italian", languageCode: .Italian),
    AppLanguage(LocalName: "한국인", image: .korean, englishName: "korean", languageCode: .Korean),
    AppLanguage(LocalName: "Português", image: .portugal, englishName: "Portuguese", languageCode: .Portuguese),
    AppLanguage(LocalName: "Española", image: .spanish, englishName: "Spanish", languageCode: .Spanish),
    AppLanguage(LocalName: "Türkçe", image: .turkey, englishName: "Turkish", languageCode: .Turkish),
    
    AppLanguage(LocalName: "Dansk", image: .danish, englishName: "Danish", languageCode: .Danish),
    AppLanguage(LocalName: "Nederlands", image: .dutch, englishName: "Dutch", languageCode: .Dutch),
    AppLanguage(LocalName: "日本語", image: .danish, englishName: "Japanese", languageCode: .Japanese),
    AppLanguage(LocalName: "Русский", image: .dutch, englishName: "Russian", languageCode: .Russian)
]


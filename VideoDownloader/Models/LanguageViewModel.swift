//
//  LanguageViewModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import Foundation
import Combine
import SwiftUI

class LanguageViewModel: BaseViewModel {
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    @Published var selectedLanguage: Language?
}

//
//  CreateFolderAlert.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 19/03/26.
//

import SwiftUI

struct CreateFolderAlert: ViewModifier {
    @Binding var isPresented: Bool
    var onCreate: (String) -> Void
    @State private var folderName = ""
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    func body(content: Content) -> some View {
        content
            .alert("Create New Folder".localized(language), isPresented: $isPresented) {
                TextField("Folder Name".localized(language), text: $folderName)
                    .textInputAutocapitalization(.words)
                
                Button("Cancel".localized(language), role: .cancel) {
                    folderName = ""
                }
                
                Button("Create".localized(language)) {
                    if !folderName.trimmingCharacters(in: .whitespaces).isEmpty {
                        onCreate(folderName.trimmingCharacters(in: .whitespaces))
                        folderName = ""
                    }
                }
            } message: {
                Text("Enter a name for your new folder".localized(language))
            }
    }
}

extension View {
    func createFolderAlert(isPresented: Binding<Bool>, onCreate: @escaping (String) -> Void) -> some View {
        modifier(CreateFolderAlert(isPresented: isPresented, onCreate: onCreate))
    }
}

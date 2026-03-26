//
//  SharedAppStorage.swift
//  Trans News
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

enum SharedAppStorage {
    static let appGroupID = "group.NEWS.Trans-News"
    static let selectedLanguageKey = "selectedLanguage"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func syncSelectedLanguage(_ language: String) {
        sharedDefaults?.set(language, forKey: selectedLanguageKey)
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    static func currentSelectedLanguage() -> String {
        sharedDefaults?.string(forKey: selectedLanguageKey)
            ?? UserDefaults.standard.string(forKey: selectedLanguageKey)
            ?? "id"
    }
}

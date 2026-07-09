//
//  UserDefault+Extension.swift
//  Template iOS
//
//  Created by QUENV1 on 22/12/2022.
//

import Foundation

import Foundation

enum UserDefaultKeys {
    static let languageChangeKey = "languageChangeKey"
    static let firstInstallAppKey = "firstInstallAppKey"
    static let firstRequestATTAppKey = "firstRequestATTAppKey"
    static let currentRatingCountKey = "currentRatingCountKey"
    static let hasUserActionRatingKey = "hasUserActionRatingKey"
}

extension UserDefaults {
    
    var currentLanguage: String? {
        get { object(forKey: UserDefaultKeys.languageChangeKey) as? String }
        set { set(newValue, forKey: UserDefaultKeys.languageChangeKey) }
    }
    
    var firstInstall: Bool {
        get { (object(forKey: UserDefaultKeys.firstInstallAppKey) as? Bool) ?? true }
        set { set(newValue, forKey: UserDefaultKeys.firstInstallAppKey) }
    }

    var firstRequestATT: Bool {
        get { (object(forKey: UserDefaultKeys.firstRequestATTAppKey) as? Bool) ?? true }
        set { set(newValue, forKey: UserDefaultKeys.firstRequestATTAppKey) }
    }
    
    var currentRatingCount: Int {
        get { (object(forKey: UserDefaultKeys.currentRatingCountKey) as? Int) ?? 0 }
        set { set(newValue, forKey: UserDefaultKeys.currentRatingCountKey) }
    }
    
    var hasUserActionRating: Bool {
        get { (object(forKey: UserDefaultKeys.hasUserActionRatingKey) as? Bool) ?? false }
        set { set(newValue, forKey: UserDefaultKeys.hasUserActionRatingKey) }
    }
}

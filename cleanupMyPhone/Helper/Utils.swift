//
//  Utils.swift
//  GPSTracker
//
//  Created by Que Nguyen on 03/09/2023.
//

import Foundation
import UIKit

final class Utils {
    static var isAllowShowResumeAds: Bool = true
    static var configAds: AdsConfiguration = AdsConfiguration()
    static var isOnFirstScreen: Bool = false
    static var isShowingAlert: Bool = false

    class func fetchAndUpdateRemoteConfig() {
        RemoteConfigManager.shared.fetchData { _ in
            if let configs = RemoteConfigManager.shared.getValue(fromKey: .adsConfigs), let data = configs.data(using: .utf8) {
                if let result = try? JSONDecoder().decode(AdsConfiguration.self, from: data) {
                    Utils.configAds = result
                    print("Receive ads configs: \(result)")
                }
            }
        }
    }
}

struct AdsConfiguration: Codable {
    var version_reviewing: String = ""
    var enable_all_ads: Bool = true
    var enable_rating: Bool = true

    var enable_inter_splash: Bool = true
    var enable_native_language: Bool = true
    var enable_native_language_1: Bool = true
    var enable_native_language_setting: Bool = true
    var enable_native_intro: Bool = true
    var enable_native_intro_2: Bool = true
    var enable_open_resume: Bool = true

    var current_version: String {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String else {
                return ""
        }
        return currentVersion
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version_reviewing = (try? container.decode(String.self, forKey: .version_reviewing)) ?? ""
        if current_version == self.version_reviewing, !self.version_reviewing.isEmpty {
            self.enable_all_ads = false
            self.enable_rating = false
        } else {
            self.enable_all_ads = try container.decode(Bool.self, forKey: .enable_all_ads)
            self.enable_rating = (try? container.decode(Bool.self, forKey: .enable_rating))  ?? true
        }
        self.enable_inter_splash = (try? container.decode(Bool.self, forKey: .enable_inter_splash)) ?? true
        self.enable_native_language = (try? container.decode(Bool.self, forKey: .enable_native_language)) ?? true
        self.enable_native_language_1 = (try? container.decode(Bool.self, forKey: .enable_native_language_1)) ?? true
        self.enable_native_intro = (try? container.decode(Bool.self, forKey: .enable_native_intro)) ?? true
        self.enable_native_intro_2 = (try? container.decode(Bool.self, forKey: .enable_native_intro_2)) ?? true
        self.enable_open_resume = (try? container.decode(Bool.self, forKey: .enable_open_resume)) ?? true
    }
}

func changeLanguage(to language: String) {
    UserDefaults.standard.currentLanguage = language
    NotificationCenter.default.post(name: .languageDidChange, object: nil)
}

extension Notification.Name {
    static let languageDidChange = Notification.Name("LanguageDidChange")
    static let notificationRecieve = Notification.Name("com.recieve.notification")
}

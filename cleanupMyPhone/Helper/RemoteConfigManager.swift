//
//  RemoteConfigManager.swift
//  Common Services
//
//  Created by QUENV1 on 11/02/2023.
//

import Foundation
import Firebase
import FirebaseRemoteConfig
import RxSwift
import RxCocoa

enum RemoteConfigKey: String {
    case configAppVersion = "config_app_version"
    case adsConfigs = "ads_configs"
}

final class RemoteConfigManager {
    static let shared: RemoteConfigManager = RemoteConfigManager()
    let remoteConfig: RemoteConfig

    init() {
        guard let app = FirebaseApp.app() else {
            fatalError("Cannot init FirebaseApp")
        }
        remoteConfig = RemoteConfig.remoteConfig(app: app)
        let settings = RemoteConfigSettings()
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "DefaultRemoteConfigValues")
        remoteConfig.ensureInitialized { [weak self] error in
            if let error = error {
#if DEBUG
                print("🤯🤯🤯 \(error.localizedDescription)")
#endif
            }
            self?.fetchData(completion: { _ in } )
        }
    }
    
    func getValue(fromKey key: RemoteConfigKey) -> String? {
        if let value = self.remoteConfig.configValue(forKey: key.rawValue).stringValue {
            return value
        }
        return nil
    }
    
    func getBoolValue(fromKey key: RemoteConfigKey) -> Bool? {
        let value = self.remoteConfig.configValue(forKey: key.rawValue).boolValue
        return value
    }
    
    func getIntValue(fromKey key: RemoteConfigKey) -> Int? {
        let numberValue = self.remoteConfig.configValue(forKey: key.rawValue).numberValue
        return numberValue.intValue
    }
    
    func fetchData(completion: @escaping((Bool) -> Void)) {
        remoteConfig.fetch(withExpirationDuration: TimeInterval(0)) { (status, _) in
            print("RemoteConfigManager fetchRemoteConfig status = \(status.rawValue)")
            if status == RemoteConfigFetchStatus.success {
                self.remoteConfig.activate { _, err in
                    completion(err == nil)
                }
                return
            }
            completion(false)
        }
    }
}



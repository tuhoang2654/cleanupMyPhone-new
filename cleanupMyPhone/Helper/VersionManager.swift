//
//  VersionManager.swift
//  WorkerHandbook
//
//  Created by QUENV1 on 09/02/2023.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

enum VersionUpdate: String {
    case force
    case recommend
    case none
}

typealias UpdateAppResult = (VersionUpdate, isShow: Bool)

final class VersionManager {
    static let shared: VersionManager = VersionManager()
    lazy var remoteConfig: RemoteConfigManager = RemoteConfigManager()
    let disposeBag = DisposeBag()
    
    func checkUpdate(completion: @escaping ((UpdateAppResult)-> Void)) {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String else {
                completion(UpdateAppResult(.none, isShow: false))
                return
        }
        
        remoteConfig.fetchData(completion: {[weak self] _ in
            guard let self = self else { return }
            if let versionUpdateData = self.remoteConfig.getValue(fromKey: .configAppVersion), let dictData = convertToDictionary(versionUpdateData) {
                print(dictData)
                if let latestVersion = dictData["latest_version"] as? String {
                    if currentVersion.compare(latestVersion) == .orderedAscending {
                        if let isForce = dictData["isForce"] as? Bool, isForce {
                            //force ko cần check isShow
                            completion(UpdateAppResult(.force, isShow: true))
                        } else if let isDisplay = dictData["isDisplay"] as? Bool {
                            completion(UpdateAppResult(.recommend, isShow: isDisplay))
                        }
                        return
                    }
                }
             }
            completion(UpdateAppResult(.none, isShow: false))

        })
    }
}

func convertToDictionary(_ text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

//
//  InterAdHelper.swift
//  Template iOS
//
//  Created by Que Nguyen on 05/10/2023.
//

import Foundation
import GoogleMobileAds

class InterAdHelper {
    
    static var interstitial: GADInterstitialAd?
    static var lastDateCallInterSuccess: Date?

    class func loadInterAds(id: String, isEnabled: Bool, isShowLoading: Bool = true, completion: @escaping ((Bool) -> Void)) {
        if isShowLoading {
            DispatchQueue.main.async {
                LoadingManager.shared.show(in: nil)
            }
        }
     
        guard isNeedShowInterAds() else {
            hideLoading(isCompleted: false)
            return
        }
        InterAdHelper.interstitial = nil
        guard Utils.configAds.enable_all_ads, isEnabled else {
            hideLoading(isCompleted: false)
            return
        }
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: id,
                                       request: request,
                             completionHandler: { ad, error in
                               if let error = error {
                                 print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                   hideLoading(isCompleted: false)
                                 return
                               }
                                InterAdHelper.interstitial = ad
                                Self.lastDateCallInterSuccess = Date()
                                ad?.paidEventHandler = { event in
                                    ROI360Service.shared.logEvent(event, adUnit: id, adType: "Inter")
                                }
                                hideLoading(isCompleted: true)
                             })
        
        func hideLoading(isCompleted: Bool) {
            guard isShowLoading else {
                completion(isCompleted)
                return
            }
            DispatchQueue.main.async {
                LoadingManager.shared.hide {
                    completion(isCompleted)
                }
            }
        }
    }
    
    class func isNeedShowInterAds() -> Bool {
        if Self.lastDateCallInterSuccess == nil {
             return true
        }
        let now = Date()
        if let lastDateCallInterSuccess = Self.lastDateCallInterSuccess {
            let differenceInSeconds = Int(now.timeIntervalSince(lastDateCallInterSuccess))
            if differenceInSeconds >= 30 {
                return true
            }
        }
        return false
    }
}

struct NotificationName {
    public static let dismissAlert = Notification.Name("NotificationName.cancelAlert")
}

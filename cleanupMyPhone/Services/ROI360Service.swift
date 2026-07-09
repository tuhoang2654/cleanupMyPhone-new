//
//  ROI360Services.swift
//  ClapFindPhone
//
//  Created by QueNguyen on 19/03/2024.
//

import Foundation
import AppsFlyerAdRevenue
import GoogleMobileAds

final class ROI360Service: NSObject {
    static let shared = ROI360Service()
    func logEvent(_ event: GADAdValue, adUnit: String, adType: String, place: String? = nil) {
        let adRevenueParams:[AnyHashable: Any] = [
                            kAppsFlyerAdRevenueCountry : Locale.current.identifier,
                            kAppsFlyerAdRevenueAdUnit : adUnit,
                            kAppsFlyerAdRevenueAdType : adType,
                            kAppsFlyerAdRevenuePlacement : place ?? ""
                        ]
                        
        AppsFlyerAdRevenue.shared().logAdRevenue(
            monetizationNetwork: "admob",
            mediationNetwork: MediationNetworkType.googleAdMob,
            eventRevenue: event.value,
            revenueCurrency: event.currencyCode,
            additionalParameters: adRevenueParams)
    }
}

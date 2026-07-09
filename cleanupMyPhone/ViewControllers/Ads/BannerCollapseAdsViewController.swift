//
//  BaseBannerAdsViewController.swift
//  GPSTracker
//
//  Created by Que Nguyen on 05/10/2023.
//

import Foundation
import UIKit
import GoogleMobileAds

class BannerCollapseAdsViewController: UIViewController, GADBannerViewDelegate {
    var bannerView: GADBannerView!
    
    func loadCollapseBannerAd(frameWidth: CGFloat, targetView: UIView? = nil) {
        guard Utils.configAds.enable_all_ads, Utils.configAds.enable_all_ads else {
            didFailToReceiveAd()
            return
        }
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        //        bannerView.adUnitID = AdsId.banner_collapse
        bannerView.rootViewController = self
        let viewWidth = frameWidth
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        let request = GADRequest()
        
        // Create an extra parameter that aligns the bottom of the expanded ad to
        // the bottom of the bannerView.
        let extras = GADExtras()
        extras.additionalParameters = ["collapsible" : "bottom"]
        request.register(extras)
        addBannerViewToView(bannerView, targetView: targetView)
        
        bannerView.load(request)
        didReceiveAds()
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView, targetView: UIView? = nil) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        if let targetView = targetView {
            targetView.addSubview(bannerView)
            targetView.addConstraints([NSLayoutConstraint(item: bannerView,
                                                          attribute: .bottom,
                                                          relatedBy: .equal,
                                                          toItem: targetView,
                                                          attribute: .bottom,
                                                          multiplier: 1,
                                                          constant: 0),
                                       NSLayoutConstraint(item: bannerView,
                                                          attribute: .centerX,
                                                          relatedBy: .equal,
                                                          toItem: targetView,
                                                          attribute: .centerX,
                                                          multiplier: 1,
                                                          constant: 0)
            ])
            return
        }
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    open func didReceiveAds() {
        
    }
    
    open func didFailToReceiveAd() {
        
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
        didReceiveAds()
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}

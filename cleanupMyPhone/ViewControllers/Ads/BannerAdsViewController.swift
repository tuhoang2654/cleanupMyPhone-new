//
//  BannerAdsViewController.swift
//  GPSTracker
//
//  Created by Que Nguyen on 09/11/2023.
//

import Foundation
import UIKit
import GoogleMobileAds
import SnapKit

class BannerAdsViewController: UIViewController, GADBannerViewDelegate {
    @IBOutlet weak var bannerView: GADBannerView!
    lazy var activity: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    open var isEnableAds: Bool {
        fatalError("Must Override")
    }
    
    func configAds() {
        //        bannerView.adUnitID = AdsId.banner_item
        bannerView.rootViewController = self
        view.addSubview(activity)
        view.bringSubviewToFront(activity)
        activity.snp.makeConstraints { make in
            make.centerY.equalTo(bannerView.snp.centerY)
            make.centerX.equalTo(bannerView.snp.centerX)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadBannerAd()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.loadBannerAd()
        })
    }
    
    func loadBannerAd() {
        activity.startAnimating()
        guard Utils.configAds.enable_all_ads, isEnableAds else {
            activity.stopAnimating()
            activity.removeFromSuperview()
            didFailToReceiveAd()
            return
        }
        // Step 2 - Determine the view width to use for the ad width.
        let frame = { () -> CGRect in
            // Here safe area is taken into account, hence the view frame is used
            // after the view has been laid out.
            //            if #available(iOS 11.0, *) {
            //                return view.frame.inset(by: view.safeAreaInsets)
            //            } else {
            return view.frame
            //            }
        }()
        let viewWidth = frame.size.width
        
        // Step 3 - Get Adaptive GADAdSize and set the ad view.
        // Here the current interface orientation is used. If the ad is being preloaded
        // for a future orientation change or different orientation, the function for the
        // relevant orientation should be used.
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.delegate = self
        // Step 4 - Create an ad request and load the adaptive banner ad.
        bannerView.load(GADRequest())
    }
    
    open func didReceiveAds() { }
    
    open func didFailToReceiveAd() {}
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
        didReceiveAds()
        activity.stopAnimating()
        activity.removeFromSuperview()
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        didFailToReceiveAd()
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

//
//  BaseNativeAdvanceAdsViewController.swift
//  GPSTracker
//
//  Created by Que Nguyen on 05/10/2023.
//

import Foundation
import UIKit
import GoogleMobileAds
import SnapKit

class BaseNativeAdvanceAdsViewController: UIViewController, GADNativeAdLoaderDelegate, GADNativeAdDelegate, GADVideoControllerDelegate {
    @IBOutlet weak var placeHolderAds: PlaceHolderAdsView!
    @IBOutlet weak var heightPlaceHolder: NSLayoutConstraint!
    
    /// The height constraint applied to the ad view, where necessary.
    var heightConstraint: NSLayoutConstraint?
    
    /// The ad loader. You must keep a strong reference to the GADAdLoader during the ad loading
    /// process.
    var adLoader: GADAdLoader!
    
    /// The native ad view that is being presented.
    var nativeAdView: GADNativeAdView!
    var id2: String?
    
    open func didFailToReceiveAd() {}
    open func didReceiveAd() {}
    
    func configAds(id: String, id2: String? = nil, isEnabled: Bool, position: AdsPosition) {
        placeHolderAds.backgroundColor = .clear
        guard Utils.configAds.enable_all_ads, isEnabled else {
            heightPlaceHolder.constant = 1
            placeHolderAds.isHidden = true
            didFailToReceiveAd()
            return
        }
        self.id2 = id2
        guard
            let nibObjects = Bundle.main.loadNibNamed(position.rawValue, owner: nil, options: nil),
            let adView = nibObjects.first as? GADNativeAdView
        else {
            return
        }
        adView.backgroundColor = .clear
        setAdView(adView)
        self.adLoader = GADAdLoader(adUnitID: id,
                                    rootViewController: self,
                                    adTypes: [ .native ],
                                    options: [])
        
        self.adLoader.delegate = self
        self.adLoader.load(GADRequest())
    }
    
    
    func setAdView(_ view: GADNativeAdView) {
        // Remove the previous ad view.
        nativeAdView = view
        nativeAdView.isHidden = true
        placeHolderAds.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for positioning the native ad view to stretch the entire width and height
        // of the nativeAdPlaceholder.
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        placeHolderAds.isHidden = true
        heightPlaceHolder.constant = 1
        placeHolderAds.stopLoading()
        if let id2 = id2, adLoader.adUnitID != id2 {
            self.adLoader = GADAdLoader(adUnitID: id2,
                                        rootViewController: self,
                                        adTypes: [ .native ],
                                        options: [])
            self.adLoader.load(GADRequest())
        }
        didFailToReceiveAd()
    }
    
    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeAd: GADNativeAd) {
        placeHolderAds.stopLoading()
        nativeAdView.isHidden = false
        placeHolderAds.isHidden = false
        heightPlaceHolder.constant = 258
        // Set ourselves as the native ad delegate to be notified of native ad events.
        nativeAd.delegate = self
        didReceiveAd()
        // Deactivate the height constraint that was set when the previous video ad loaded.
        heightConstraint?.isActive = false
        nativeAd.paidEventHandler = {[weak self] event in
            ROI360Service.shared.logEvent(event, adUnit: self?.adLoader.adUnitID ?? "", adType: "NativeAdvanced", place: "NativeAdvancedDefault")
        }
        // Populate the native ad view with the native ad assets.
        // The headline and mediaContent are guaranteed to be present in every native ad.
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        nativeAdView.mediaView?.isHidden = false
        
        // Some native ads will include a video asset, while others do not. Apps can use the
        // GADVideoController's hasVideoContent property to determine if one is present, and adjust their
        // UI accordingly.
        let mediaContent = nativeAd.mediaContent
        if mediaContent.hasVideoContent {
            // By acting as the delegate to the GADVideoController, this ViewController receives messages
            // about events in the video lifecycle.
            mediaContent.videoController.delegate = self
        } else {
        }
        
        // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
        // ratio of the media it displays.
        //        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
        //          heightConstraint = NSLayoutConstraint(
        //            item: mediaView,
        //            attribute: .height,
        //            relatedBy: .equal,
        //            toItem: mediaView,
        //            attribute: .width,
        //            multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
        //            constant: 0)
        //          heightConstraint?.isActive = true
        //        }
        
        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.isHidden = false
        (nativeAdView.callToActionView as? UIButton)?.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 16)
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction?.uppercased(), for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        // Associate the native ad view with the native ad object. This is
        // required to make the ad clickable.
        // Note: this should always be done after populating the ad views.
        nativeAdView.nativeAd = nativeAd
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        // The adLoader has finished loading ads, and a new request can be sent.
    }
    
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
        print("Video playback has ended.")
    }
}

enum AdsPosition: String {
    case top = "NativeAdView"
    case bottom = "NativeAdBottomView"
}

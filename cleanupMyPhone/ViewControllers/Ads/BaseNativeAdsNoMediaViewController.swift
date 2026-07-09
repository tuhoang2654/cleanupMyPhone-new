//
//  BaseNativeAdsNoMediaViewController.swift
//  GPSTracker
//
//  Created by Que Nguyen on 07/10/2023.
//

import Foundation
import UIKit
import GoogleMobileAds

class BaseNativeAdsNoMediaViewController: UIViewController, GADNativeAdLoaderDelegate, GADNativeAdDelegate, GADVideoControllerDelegate {
    @IBOutlet weak var placeHolderAds: PlaceHolderAdsView!
    @IBOutlet weak var heightPlaceHolder: NSLayoutConstraint!
    
    /// The height constraint applied to the ad view, where necessary.
    var heightConstraint: NSLayoutConstraint?
    var adUnit: String = ""
    var resultNativeAd: GADNativeAd?
    
    /// The ad loader. You must keep a strong reference to the GADAdLoader during the ad loading
    /// process.
    var adLoader: GADAdLoader!
    
    /// The native ad view that is being presented.
    var nativeAdView: GADNativeAdView!
    
    func configAds(id: String, isEnabled: Bool, position: AdsNoMediaPosition = .bottom) {
        placeHolderAds.backgroundColor = .clear
        guard Utils.configAds.enable_all_ads, isEnabled else {
            heightPlaceHolder.constant = 1
            placeHolderAds.isHidden = true
            loadAdsFail()
            return
        }
        guard
            let nibObjects = Bundle.main.loadNibNamed(position.rawValue, owner: nil, options: nil),
            let adView = nibObjects.first as? GADNativeAdView
        else {
            return
        }
        adView.backgroundColor = .clear
        setAdView(adView)
        adUnit = id
        adLoader = GADAdLoader(adUnitID: id,
                               rootViewController: self,
                               adTypes: [ .native ],
                               options: [])
        
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    func setAdView(_ view: GADNativeAdView) {
        // Remove the previous ad view.
        nativeAdView = view
        placeHolderAds.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.isHidden = true
        
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
        loadAdsFail()
        placeHolderAds.stopLoading()
    }
    
    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeAd: GADNativeAd) {
        resultNativeAd = nativeAd
        handleAds()
    }
    
    // can override
    open func handleAds() {
        showNativeAds()
    }
    
    func showNativeAds() {
        guard let nativeAd = resultNativeAd else { return }
        placeHolderAds.stopLoading()
        nativeAdView.isHidden = false
        loadAdsSuccessfull()
        placeHolderAds.isHidden = false
        heightPlaceHolder.constant = 155
        // Set ourselves as the native ad delegate to be notified of native ad events.
        nativeAd.delegate = self
        nativeAd.paidEventHandler = {[weak self] event in
            ROI360Service.shared.logEvent(event, adUnit: self?.adUnit ?? "", adType: "Native", place: "NativeDefault")
        }
        // Deactivate the height constraint that was set when the previous video ad loaded.
        heightConstraint?.isActive = false
        
        // Populate the native ad view with the native ad assets.
        // The headline and mediaContent are guaranteed to be present in every native ad.
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        
        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        (nativeAdView.callToActionView as? UIButton)?.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 16)
        
        //        (nativeAdView.callToActionView as? UIButton)?.backgroundColor = Colors.primarya500Sub
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
    
    open func loadAdsSuccessfull() {
        
    }
    
    open func loadAdsFail() {
        
    }
}

enum AdsNoMediaPosition: String {
    case top = "NativeAdNoMediaView"
    case bottom = "NativeAdNoMediaBottomView"
}

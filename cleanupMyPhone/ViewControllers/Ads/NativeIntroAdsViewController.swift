//
//  NativeIntroAdsViewController.swift
//  GPSTracker
//
//  Created by Que Nguyen on 29/11/2023.
//

import Foundation
import UIKit
import GoogleMobileAds
import SnapKit

class NativeIntroAdsViewController: UIViewController, GADNativeAdLoaderDelegate, GADNativeAdDelegate, GADVideoControllerDelegate {
    @IBOutlet weak var placeHolderAds: PlaceHolderAdsView!
    @IBOutlet weak var heightPlaceHolder: NSLayoutConstraint!
    
    /// The height constraint applied to the ad view, where necessary.
    var heightConstraint: NSLayoutConstraint?
    
    /// The ad loader. You must keep a strong reference to the GADAdLoader during the ad loading
    /// process.
    var adLoader1: GADAdLoader!
    var adLoader2: GADAdLoader!
    var adLoader3: GADAdLoader!
    
    var dictAds: [Int: GADNativeAd] = [:]
    
    /// The native ad view that is being presented.
    var nativeAdView: GADNativeAdView!
    var id1: String = ""
    var id3: String = ""
    var id2: String = ""
    
    open func didFailToReceiveAd() {}
    open func didReceiveAd() {}
    
    func loadAds(index: Int) {
        if let ads = dictAds[index] {
            if index == 0 {
                loadAdsToView(nativeAd: ads)
            } else if index == 1 {
                loadAdsToView(nativeAd: ads)
            } else if index == 2 {
                loadAdsToView(nativeAd: ads)
            }
        }
    }
    
    func configAds(id1: String, id2: String, id3: String, position: AdsPosition) {
        placeHolderAds.backgroundColor = .clear
        heightPlaceHolder.constant = 0
        placeHolderAds.isHidden = true
        guard Utils.configAds.enable_all_ads, Utils.configAds.enable_native_intro else {
            heightPlaceHolder.constant = 0
            placeHolderAds.isHidden = true
            didFailToReceiveAd()
            return
        }
        self.id1 = id1
        self.id2 = Utils.configAds.enable_native_intro_2 ? id2 : ""
        self.id3 = id3
        
        guard
            let nibObjects = Bundle.main.loadNibNamed(position.rawValue, owner: nil, options: nil),
            let adView = nibObjects.first as? GADNativeAdView
        else {
            return
        }
        adView.backgroundColor = .clear
        setAdView(adView)
        self.adLoader1 = GADAdLoader(adUnitID: id1,
                                     rootViewController: self,
                                     adTypes: [ .native ],
                                     options: [])
        
        self.adLoader1.delegate = self
        self.adLoader1.load(GADRequest())
        
        if !self.id2.isEmpty {
            self.adLoader2 = GADAdLoader(adUnitID: self.id2,
                                         rootViewController: self,
                                         adTypes: [ .native ],
                                         options: [])
            
            self.adLoader2.delegate = self
            self.adLoader2.load(GADRequest())
        }
        
        self.adLoader3 = GADAdLoader(adUnitID: id3,
                                     rootViewController: self,
                                     adTypes: [ .native ],
                                     options: [])
        
        self.adLoader3.delegate = self
        self.adLoader3.load(GADRequest())
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
        heightPlaceHolder.constant = 0
        placeHolderAds.stopLoading()
    }
    
    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeAd: GADNativeAd) {
        var adUnit: String = ""
        if adLoader == adLoader1 {
            dictAds[0] = nativeAd
            adUnit = id1
        } else if adLoader == adLoader2 {
            dictAds[1] = nativeAd
            adUnit = id2
        } else if adLoader == adLoader3 {
            dictAds[2] = nativeAd
            adUnit = id3
        }
        guard adLoader == adLoader1 else { return }
        nativeAd.paidEventHandler = { event in
            ROI360Service.shared.logEvent(event, adUnit: adUnit, adType: "NativeAdvanced", place: "NativeAdvancedDefault")
        }
        loadAdsToView(nativeAd: nativeAd)
    }
    
    func loadAdsToView(nativeAd: GADNativeAd) {
        placeHolderAds.stopLoading()
        nativeAdView.isHidden = false
        placeHolderAds.isHidden = false
        heightPlaceHolder.constant = 310
        // Set ourselves as the native ad delegate to be notified of native ad events.
        nativeAd.delegate = self
        didReceiveAd()
        // Deactivate the height constraint that was set when the previous video ad loaded.
        heightConstraint?.isActive = false
        
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

//
//  AppDelegate.swift
//  TemplateiOS
//
//  Created by QueNguyen on 23/12/2023.
//

import UIKit
import FirebaseCore
import AppsFlyerLib
import GoogleMobileAds
import FBSDKCoreKit
import UserMessagingPlatform

let appId: String = "" // APP ID on Apple store, ex: 6465135415

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var isMobileAdsStartCalled = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Utils.fetchAndUpdateRemoteConfig()
        requestUMP()

        GADMobileAds.sharedInstance().start(completionHandler: nil)
                
        AppsFlyerLib.shared().appsFlyerDevKey = "Qhno4yJY6KHmZp9uS9DRe4"
        AppsFlyerLib.shared().appleAppID = appId
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().start()
        //check update app
        checkUpdateAppIfNeeded()
        AppEvents.shared.activateApp()
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func checkUpdateAppIfNeeded() {
        VersionManager.shared.checkUpdate { result in
            switch result.0 {
            case .force:
                Utils.isShowingAlert = true
                DispatchQueue.main.async {
                    UIApplication.topViewController(controller: nil)?.showForceAlert(message: L10n.TemplateiOS.Alert.Update.message, title: L10n.TemplateiOS.Alert.Update.title, okAction: {
                        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appId)") else {
                            return
                        }
                        UIApplication.shared.open(url)
                    })
                }
            case .recommend:
                if result.isShow {
                    Utils.isShowingAlert = true
                    DispatchQueue.main.async {
                        UIApplication.topViewController(controller: nil)?.showConfirmAlert(message: L10n.TemplateiOS.Alert.Update.message, okAction: {
                            guard let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appId)") else {
                                return
                            }
                            UIApplication.shared.open(url)
                        }, cancelAction: {
                            Utils.isShowingAlert = false
                            NotificationCenter.default.post(name: NotificationName.dismissAlert, object: nil)
                        })
                    }
                }
            default:
                Utils.isShowingAlert = false
                return
            }
        }
    }
    
    func requestUMP() {
        
        // Request an update for the consent information.
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: nil) {
            [weak self] requestConsentError in
            guard let self else { return }
            
            if let consentError = requestConsentError {
                // Consent gathering failed.
                Utils.isShowingAlert = false
                return print("Error: \(consentError.localizedDescription)")
            }
            Utils.isShowingAlert = true
            if let topVC = UIApplication.topViewController(controller: nil) {
                UMPConsentForm.loadAndPresentIfRequired(from: topVC) {
                    [weak self] loadAndPresentError in
                    guard let self else { return }
                    
                    if let consentError = loadAndPresentError {
                        // Consent gathering failed.
                        return print("Error: \(consentError.localizedDescription)")
                    }
                    
                    // Consent has been gathered.
                    if UMPConsentInformation.sharedInstance.canRequestAds {
                        self.startGoogleMobileAdsSDK()
                        Utils.isShowingAlert = false
                        NotificationCenter.default.post(name: NotificationName.dismissAlert, object: nil)
                    }
                }
            }
        }
        
        // Check if you can initialize the Google Mobile Ads SDK in parallel
        // while checking for new consent information. Consent obtained in
        // the previous session can be used to request ads.
        if UMPConsentInformation.sharedInstance.canRequestAds {
            startGoogleMobileAdsSDK()
            Utils.isShowingAlert = false
            NotificationCenter.default.post(name: NotificationName.dismissAlert, object: nil)
        }
    }

  private func startGoogleMobileAdsSDK() {
    DispatchQueue.main.async {
      guard !self.isMobileAdsStartCalled else { return }

      self.isMobileAdsStartCalled = true

      // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
    }
  }
}


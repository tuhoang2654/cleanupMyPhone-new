//
//  SceneDelegate.swift
//  TemplateiOS
//
//  Created by QueNguyen on 23/12/2023.
//

import UIKit
import GoogleMobileAds
import AppsFlyerLib
import FBSDKCoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, GADFullScreenContentDelegate {

    var window: UIWindow?
    var appOpenAd: GADAppOpenAd?
    var loadTime = Date()
    static var isInactive: Bool = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("sendLaunch"), name: UIApplication.didBecomeActiveNotification, object: nil)

    }

    @objc func sendLaunch() {
        AppsFlyerLib.shared().start()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        checkUpdateAppIfNeeded(completion: {[weak self] status in
            if !status, !Utils.isOnFirstScreen {
                DispatchQueue.main.async {[weak self] in
                    self?.requestAppOpenAd()
                }
            }
        })
        AppEvents.shared.activateApp()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        Self.isInactive = true
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        LoadingManager.shared.hide(completion: {
            Utils.isAllowShowResumeAds = true
        })
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Utils.isAllowShowResumeAds = true
    }

    func requestAppOpenAd() {
        if Self.isInactive && Utils.isAllowShowResumeAds {
            Self.isInactive = false
            guard Utils.configAds.enable_all_ads, Utils.configAds.enable_open_resume, !LoadingManager.shared.isLoading else { return }
            let request = GADRequest()
            LoadingManager.shared.show(in: nil, isHiddenText: false)
            GADAppOpenAd.load(withAdUnitID: AdsId.open_resume,
                              request: request,
                              completionHandler: {[weak self] (appOpenAdIn, err) in
                guard let appOpenAdIn = appOpenAdIn else {
                    print(err?.localizedDescription)
                    LoadingManager.shared.hide(completion: {})
                    return
                }
                self?.appOpenAd = appOpenAdIn
                self?.appOpenAd?.fullScreenContentDelegate = self
                self?.appOpenAd?.paidEventHandler = { event in
                    ROI360Service.shared.logEvent(event, adUnit: AdsId.open_resume, adType: "AppOpen", place: "AppOpenDefault")
                }
                Utils.isAllowShowResumeAds = false
                LoadingManager.shared.hide {[weak self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {[weak self] in
                        if let rwc = UIApplication.topViewController(controller: nil) {
                            print(rwc)
                            self?.appOpenAd?.present(fromRootViewController: rwc)
                        }
                    })
                }
            })
        }
        Self.isInactive = false
    }
    
    func checkUpdateAppIfNeeded(completion: @escaping((Bool) -> Void)) {
        VersionManager.shared.checkUpdate { result in
            var hasShowPopUp: Bool = false
            switch result.0 {
            case .force:
                DispatchQueue.main.async {
                    UIApplication.topViewController(controller: nil)?.showForceAlert(message: L10n.TemplateiOS.Alert.Update.message, title: L10n.TemplateiOS.Alert.Update.title, okAction: {
                        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appId)") else {
                            return
                        }
                        UIApplication.shared.open(url)
                    })
                }
                Utils.isShowingAlert = true
                hasShowPopUp = true
            case .recommend:
                if result.isShow {
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
                    Utils.isShowingAlert = true
                    hasShowPopUp = true
                }
            default:
                Utils.isShowingAlert = false
                break
            }
            completion(hasShowPopUp)
        }
    }
}

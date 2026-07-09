//
//  UIViewController+Extension.swift
//  WorkerHandbook
//
//  Created by QUENV1 on 22/12/2022.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showErrorAlert(message: String? = nil) {
        let defaultMessage = ""
        let finalMessage = message ?? defaultMessage
        let alertController = UIAlertController(title: nil, message: finalMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: L10n.TemplateiOS.Alert.Action.ok, style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showForceAlert(message: String? = "", title: String = L10n.TemplateiOS.Alert.Action.ok, okAction: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: title, style: .cancel, handler: { _ in okAction?() }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showConfirmAlert(message: String?, okAction: @escaping (() -> Void)) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: L10n.TemplateiOS.Alert.Action.ok, style: .cancel, handler: { _ in okAction() }))
        alertController.addAction(UIAlertAction(title: L10n.TemplateiOS.Alert.Action.cancel, style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showATTPermissionAlert(okAction: @escaping (() -> Void), cancelAction: (() -> Void)?) {
        let alertController = UIAlertController(title: L10n.TemplateiOS.Alert.Att.title, message: L10n.TemplateiOS.Alert.Att.message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: L10n.TemplateiOS.Alert.Action.cancel, style: .default, handler: { _ in cancelAction?() }))
        alertController.addAction(UIAlertAction(title: L10n.TemplateiOS.Alert.settings, style: .default, handler: { _ in okAction() }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showConfirmAlert(message: String?, okAction: @escaping (() -> Void), cancelAction: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: L10n.TemplateiOS.Alert.Action.ok, style: .cancel, handler: { _ in okAction() }))
        alertController.addAction(UIAlertAction(title: L10n.TemplateiOS.Alert.Action.cancel, style: .default, handler: { _ in cancelAction?() }))
        self.present(alertController, animated: true, completion: nil)
    }

}

extension UIApplication {
    class func topViewController(controller: UIViewController?) -> UIViewController? {
        var inputController: UIViewController? = controller
        if #available(iOS 15, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene

            inputController = inputController ?? windowScene?.windows.first?.rootViewController
        } else {
            inputController = inputController ?? UIApplication.shared.windows.first?.rootViewController
        }

        if let navigationController = inputController as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = inputController as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = inputController?.presentedViewController {
            return topViewController(controller: presented)
        }
        return inputController
    }
}

extension UIViewController {
    var topPadding: CGFloat {
        var topPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            if #available(iOS 15, *) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    topPadding = windowScene.keyWindow?.safeAreaInsets.top ?? 0
                }
            } else {
                let window = UIApplication.shared.keyWindow
                topPadding = window?.safeAreaInsets.top ?? 0
            }
        }
        return topPadding
    }
    
    var bottomPadding: CGFloat {
        var topPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            if #available(iOS 15, *) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    topPadding = windowScene.keyWindow?.safeAreaInsets.bottom ?? 0
                }
            } else {
                let window = UIApplication.shared.keyWindow
                topPadding = window?.safeAreaInsets.bottom ?? 0
            }
        }
        return topPadding
    }
    
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }

        return instantiateFromNib()
    }
}

func showRatingIfNeeded() {
    if UserDefaults.standard.currentRatingCount % 4 == 0, !UserDefaults.standard.hasUserActionRating, Utils.configAds.enable_rating {
        if #available(iOS 15, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate else { return }
            let rateVC = RateViewController.loadFromNib()
            rateVC.modalPresentationStyle = .overCurrentContext
            rateVC.modalTransitionStyle = .crossDissolve
            delegate.window?.rootViewController?.present(rateVC, animated: true)
        } else {
            guard let window = UIApplication.shared.windows.first else {
                return
            }
            let rateVC = RateViewController.loadFromNib()
            rateVC.modalPresentationStyle = .overCurrentContext
            rateVC.modalTransitionStyle = .crossDissolve
            window.rootViewController?.present(rateVC, animated: true)
        }
    }
    if Utils.configAds.enable_rating {
        UserDefaults.standard.currentRatingCount += 1
        if UserDefaults.standard.currentRatingCount % 80 == 0 {
            UserDefaults.standard.hasUserActionRating = false
        }
    }
}

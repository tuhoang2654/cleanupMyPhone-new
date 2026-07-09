//
//  LoadingManager.swift
//  RemoveObject
//
//  Created by Que Nguyen on 22/05/2024.
//

import Foundation
import UIKit

final class LoadingManager {
    static let shared = LoadingManager()
    var loadingVC: LoadingViewController?
    var currentParent: UIViewController?
    var isLoading: Bool = false
    
    func show(in viewController: UIViewController?, isHiddenText: Bool = true) {
        loadingVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: LoadingViewController.className) as? LoadingViewController
        loadingVC?.modalPresentationStyle = .overCurrentContext
        isLoading = true
        // Animate loadingVC with a fade in animation
        loadingVC?.modalTransitionStyle = .crossDissolve
        loadingVC?.isHiddenText = isHiddenText
        guard let parentVC = viewController else {
            if var topController = getTopVC(), let loadingVC = loadingVC {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                currentParent = topController
                topController.present(loadingVC, animated: true, completion: nil)
            }
            return
        }
        
        currentParent = parentVC
        parentVC.present(loadingVC!, animated: true, completion: nil)

    }

    func hide(completion: (() -> Void)? = nil) {
        loadingVC?.dismiss(animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                completion?()
            })
        })
        isLoading = false
        loadingVC = nil
    }
    
    func getTopVC() -> UIViewController? {
        if #available(iOS 15, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate else { return nil }
            return delegate.window?.rootViewController
        } else {
            guard let window = UIApplication.shared.windows.first else {
                return nil
            }
            return window.rootViewController
        }
    }
}

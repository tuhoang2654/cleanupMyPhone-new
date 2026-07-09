//
//  BaseNavigation.swift
//  DeviceFinder
//
//  Created by QueNguyen on 05/01/2024.
//

import Foundation
import UIKit

protocol NavigationBaseProtocol {
    func setupBaseNavigation(isHiddenLeftButton: Bool, rightBarButton: UIBarButtonItem?, tinColor: UIColor?, titleSize: CGFloat)
}

extension UIViewController {
    @objc open func didTapLeftButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension NavigationBaseProtocol where Self: UIViewController {
    func setupBaseNavigation(isHiddenLeftButton: Bool = false, rightBarButton: UIBarButtonItem? = nil, tinColor: UIColor? = nil, titleSize: CGFloat = 20) {
        if !isHiddenLeftButton {
            let leftButton = UIBarButtonItem(image: Asset.arrowLeft.image, style: .plain, target: self, action: #selector(didTapLeftButton))
            self.navigationItem.leftBarButtonItem = leftButton
            self.navigationItem.leftBarButtonItem?.tintColor =  UIColor(hex: "#131539")
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem()
        }
        if let rightBarButton = rightBarButton {
            self.navigationItem.rightBarButtonItem = rightBarButton
            self.navigationItem.rightBarButtonItem?.tintColor = tinColor ?? UIColor(hex: "#131539")
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "LeagueSpartan-Bold", size: titleSize)!, NSAttributedString.Key.foregroundColor: UIColor(hex: "#131539")!]
    }
}

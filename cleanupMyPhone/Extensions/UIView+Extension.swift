//
//  UIView+Extension.swift
//  TemplateiOS
//
//  Created by QueNguyen on 28/06/2024.
//

import Foundation
import UIKit

extension UIView {
    func setDropShadown() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 80/255, green: 153/255, blue: 255/255, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 3.0
    }
    
    func setDropShadown2() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(hex: "#5896F7")?.withAlphaComponent(0.12).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 8.0
    }
}

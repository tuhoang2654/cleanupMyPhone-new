//
//  UILabel+Extension.swift
//  TemplateiOS
//
//  Created by Que Nguyen on 23/06/2024.
//

import Foundation
import UIKit

enum CustomFontWeight: String {
    case Regular
    case Light
    case Medium
    case SemiBold
    case Thin
    case Black
    case Bold
    case ExtraBold
    case ExtraLight
}

extension UILabel {
    func configText(_ title: String, weight: CustomFontWeight, color: UIColor?, size: CGFloat?) {
        text = title
        font = UIFont(name: "LeagueSpartan-\(weight.rawValue)", size: size ?? 20)
        textColor = color ?? UIColor(hex: "#444250")
    }
}

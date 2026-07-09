//
//  UIStackView+Extension.swift
//  GPSTracker
//
//  Created by Que Nguyen on 05/08/2023.
//

import Foundation
import UIKit

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}

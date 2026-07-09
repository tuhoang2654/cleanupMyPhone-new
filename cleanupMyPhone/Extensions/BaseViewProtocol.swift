//
//  BaseViewProtocol.swift
//  TemplateiOS5
//
//  Created by Que Nguyen on 29/10/2023.
//

import Foundation
import UIKit

private var dimBlackLayerName: String {
    return "DimBlackLayer"
}

private var dimWhiteLayerName: String {
    return "DimWhiteLayer"
}

public protocol BaseViewProtocol {

    /// Add a black layer with alpha = 0.3 to the view
    func addDimBlackLayer(path: CGPath?)

    /// Remove the black layer with alpha = 0.3 from the view
    func removeDimBlackLayer()

    /// Add a white layer with alpha = 0.3 to the view
    func addDimWhiteLayer(path: CGPath?)

    /// Remove the white layer with alpha = 0.3 from the view
    func removeDimWhiteLayer()

    /// The size of element will be decreased to 96%.
    func beginBouncingEffect()

    /// The size of element will be restored to the original.
    func endBouncingEffect()
}

extension BaseViewProtocol where Self: UIView {

    /// Add a black layer with alpha = 0.3 to the view
    public func addDimBlackLayer(path: CGPath? = nil) {
        if let sublayers = layer.sublayers {
            if sublayers.contains(where: { $0.name == dimBlackLayerName }) { return }
        }
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path ?? UIBezierPath(rect: bounds).cgPath
        layer.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
        layer.name = dimBlackLayerName
        self.layer.addSublayer(layer)
    }

    /// Remove the black layer with alpha = 0.3 from the view
    public func removeDimBlackLayer() {
        guard let subLayer = layer.sublayers else { return }
        for layer in subLayer.filter({ $0.name == dimBlackLayerName }) {
            layer.removeFromSuperlayer()
        }
    }

    /// Add a white layer with alpha = 0.3 to the view
    public func addDimWhiteLayer(path: CGPath? = nil) {
        if let sublayers = layer.sublayers {
            if sublayers.contains(where: { $0.name == dimWhiteLayerName }) { return }
        }
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path ?? UIBezierPath(rect: bounds).cgPath
        layer.fillColor = UIColor.white.withAlphaComponent(0.3).cgColor
        layer.name = dimWhiteLayerName
        self.layer.addSublayer(layer)
    }

    /// Remove the white layer with alpha = 0.3 from the view
    public func removeDimWhiteLayer() {
        guard let subLayer = layer.sublayers else { return }
        for layer in subLayer.filter({ $0.name == dimWhiteLayerName }) {
            layer.removeFromSuperlayer()
        }
    }

    //// The size of element will be decreased to 96%.
    public func beginBouncingEffect() {
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }

    /// The size of element will be restored to the original.
    public func endBouncingEffect() {
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.transform = .identity
        }
    }
    
    /// Add a black layer with custom alpha to the view
    public func addDimBlackLayer(path: CGPath? = nil, _ alpha: CGFloat = 0.3) {
        if let sublayers = layer.sublayers {
            if sublayers.contains(where: { $0.name == dimBlackLayerName }) { return }
        }
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path ?? UIBezierPath(rect: bounds).cgPath
        layer.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
        layer.name = dimBlackLayerName
        self.layer.addSublayer(layer)
    }
}

private let animationDuration = 0.1

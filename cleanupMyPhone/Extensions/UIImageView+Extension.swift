//
//  UIImage+Extension.swift
//  WorkerHandbook
//
//  Created by QUENV1 on 01/02/2023.
//

import Foundation
import Kingfisher

extension UIImageView {
     func setGrayRoundedBorder() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.layer.borderWidth = 1
         self.layer.borderColor = UIColor.black.cgColor//Colors.ink200s.cgColor
    }
}

struct SaturationImageProcessor: ImageProcessor {
    let identifier: String
    let value: CGFloat

    init(value: CGFloat = 0) {
        self.value = value
        self.identifier = "com.quenv.vn.SaturationImageProcessor.\(value)"
    }

    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            let resultImage = image.kf.scaled(to: options.scaleFactor)
            return resultImage.updateWithSaturation(value: self.value) ?? resultImage
        case .data:
            return (DefaultImageProcessor.default |> self).process(item: item, options: options)
        }
    }
}

extension UIImageView {
    var kingfisherDefaultOptionsInfo: KingfisherOptionsInfo {
        let defaultProcessor = DownsamplingImageProcessor(size: bounds.size)
        return [
            .backgroundDecode,
            .cacheOriginalImage,
            .cacheSerializer(FormatIndicatedCacheSerializer.png),
            .scaleFactor(UIScreen.main.scale),
            .processor(defaultProcessor)
        ]
    }

    func kingfisherSaturationOptionsInfo(_ value: CGFloat) -> KingfisherOptionsInfo {
        return self.kingfisherDefaultOptionsInfo + [.processor(SaturationImageProcessor(value: value))]
    }

    func setImage(with url: URL?, placeholder: UIImage?, isGrayedOut: Bool = false) {
        let options: KingfisherOptionsInfo = isGrayedOut ? self.kingfisherSaturationOptionsInfo(0) : self.kingfisherDefaultOptionsInfo
        kf.setImage(with: url, placeholder: placeholder, options: options)
    }
}

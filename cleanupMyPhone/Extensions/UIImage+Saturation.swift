//
//  UIImage+Extension.swift
//  WorkerHandbook
//
//  Created by QUENV1 on 01/02/2023.
//

import Foundation
import UIKit

extension UIImage {

    public func updateWithSaturation(value: CGFloat) -> UIImage? {
        guard let currentCGImage = self.cgImage else { return nil }
        let ciimage = CIImage(cgImage: currentCGImage)
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciimage, forKey: kCIInputImageKey)
        filter?.setValue(value, forKey: kCIInputSaturationKey)
        guard let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage,
            let cgimage = CIContext(options: nil).createCGImage(result, from: result.extent) else { return nil }
        return UIImage(cgImage: cgimage)
    }
}

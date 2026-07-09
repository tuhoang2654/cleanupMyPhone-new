//
//  PlaceHolderAdsView.swift
//  GPSTracker
//
//  Created by Que Nguyen on 10/08/2023.
//

import UIKit
import Reusable

class PlaceHolderAdsView: UIView, NibOwnerLoadable {

    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        loadNibContent()
        loadingActivity.isHidden = false
        loadingActivity.style = .large
        loadingActivity.startAnimating()
    }
    
    func stopLoading() {
        loadingActivity.stopAnimating()
        loadingActivity.isHidden = true
    }
}

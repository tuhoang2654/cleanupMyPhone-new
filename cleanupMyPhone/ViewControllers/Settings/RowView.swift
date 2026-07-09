//
//  RowView.swift
//  GPSTracker
//
//  Created by Que Nguyen on 10/08/2023.
//

import UIKit
import Reusable

class RowView: UIView, NibOwnerLoadable {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var rightIconView: UIImageView!
    @IBOutlet weak var leftIconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!

    var didTapRow: (() -> Void)?
    
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
        shadowView.setDropShadown()
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.cgColor
    }
    
    func configRow(leftIcon: UIImage?, rightIcon: UIImage = Asset.icSettingArrowRight.image, title: String, subTitle: String? = nil) {
        leftIconView.image = leftIcon
        rightIconView.image = rightIcon
        titleLabel.text = title
        subTitleLabel.text = subTitle
        subTitleLabel.isHidden = subTitle == nil
    }
    
    @IBAction func didTapView(_ sender: Any) {
        didTapRow?()
    }

}

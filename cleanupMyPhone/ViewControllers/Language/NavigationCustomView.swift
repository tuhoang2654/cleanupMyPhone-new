//
//  NavigationCustomView.swift
//  TemplateiOS
//
//  Created by Que Nguyen on 24/06/2024.
//

import Foundation
import UIKit
import Reusable

final class NavigationCustomView: UIView, NibOwnerLoadable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var rightIcon: UIImageView!

    var isEnableRightIcon: Bool = false {
        didSet {
            rightIcon.image = isEnableRightIcon ? Asset.icDoneEnable.image : Asset.icDoneDisable.image
        }
    }

    var didTapRightBarButton: (() -> Void)?

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
    }

    func config(title: String, subTitle: String) {
        titleLabel.text = title
        subTitleLabel.text = subTitle
    }

    @IBAction func didTapRightIcon(_ sender: Any) {
        guard isEnableRightIcon else { return }
        didTapRightBarButton?()
    }

}

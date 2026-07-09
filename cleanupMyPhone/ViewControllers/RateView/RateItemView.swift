//
//  RateItemView.swift
//  cleanupMyPhone
//
//  Created by Hoàng Anh Tú on 1/7/26.
//

import UIKit
import Reusable

final class RateItemView: UIView, NibOwnerLoadable {
    @IBOutlet weak var iconImage1: UIImageView!
    @IBOutlet weak var iconImage2: UIImageView!
    @IBOutlet weak var iconImage3: UIImageView!
    @IBOutlet weak var iconImage4: UIImageView!
    @IBOutlet weak var iconImage5: UIImageView!
    
    var rateCount: Int = 5
    var didRateChange: ((Int) -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        loadNibContent()
        rateCount = 5
        iconImage1.image = Asset.icRateCheck.image
        iconImage2.image = Asset.icRateCheck.image
        iconImage3.image = Asset.icRateCheck.image
        iconImage4.image = Asset.icRateCheck.image
        iconImage5.image = Asset.icRateCheck.image
    }
    
    @IBAction func didTapOne(_ sender: Any) {
        rateCount = 1
        didRateChange?(1)
        iconImage1.image = Asset.icRateCheck.image
        iconImage2.image = Asset.icRateUncheck.image
        iconImage3.image = Asset.icRateUncheck.image
        iconImage4.image = Asset.icRateUncheck.image
        iconImage5.image = Asset.icRateUncheck.image
    }
    
    @IBAction func didTapTwo(_ sender: Any) {
        rateCount = 2
        didRateChange?(2)
        iconImage1.image = Asset.icRateCheck.image
        iconImage2.image = Asset.icRateCheck.image
        iconImage3.image = Asset.icRateUncheck.image
        iconImage4.image = Asset.icRateUncheck.image
        iconImage5.image = Asset.icRateUncheck.image
    }
    
    @IBAction func didTapThree(_ sender: Any) {
        rateCount = 3
        didRateChange?(3)
        iconImage1.image = Asset.icRateCheck.image
        iconImage2.image = Asset.icRateCheck.image
        iconImage3.image = Asset.icRateCheck.image
        iconImage4.image = Asset.icRateUncheck.image
        iconImage5.image = Asset.icRateUncheck.image
    }
    
    @IBAction func didTapFour(_ sender: Any) {
        rateCount = 4
        didRateChange?(4)
        iconImage1.image = Asset.icRateCheck.image
        iconImage2.image = Asset.icRateCheck.image
        iconImage3.image = Asset.icRateCheck.image
        iconImage4.image = Asset.icRateCheck.image
        iconImage5.image = Asset.icRateUncheck.image
    }
    
    @IBAction func didTapFive(_ sender: Any) {
        rateCount = 5
        didRateChange?(5)
        iconImage1.image = Asset.icRateCheck.image
        iconImage2.image = Asset.icRateCheck.image
        iconImage3.image = Asset.icRateCheck.image
        iconImage4.image = Asset.icRateCheck.image
        iconImage5.image = Asset.icRateCheck.image
    }
}


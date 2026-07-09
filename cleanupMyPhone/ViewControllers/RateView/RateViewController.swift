//
//  RateViewController.swift
//  TemplateiOS
//
//  Created by Hoàng Anh Tú on 11/3/26.
//

import UIKit

final class RateViewController: UIViewController {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var notNowLabel: UILabel!
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var thankyouView: UIView!
    @IBOutlet weak var thankyouLabel: UILabel!
    @IBOutlet weak var rateItemView: RateItemView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        thankyouView.isHidden = true
        rateLabel.configText(L10n.TemplateiOS.Rate.Button.rate, weight: .Bold, color: .white, size: 24)
        notNowLabel.configText(L10n.TemplateiOS.Rate.Button.notNow, weight: .Light, color: nil, size: 18)
        titleLabel.configText(L10n.TemplateiOS.Rate.Normal.title, weight: .ExtraBold, color: nil, size: 20)
        subTitleLabel.configText(L10n.TemplateiOS.Rate.Normal.des, weight: .Regular, color: nil, size: 20)
        thankyouLabel.configText(L10n.TemplateiOS.Rate.thankYou, weight: .ExtraBold, color: nil, size: 20)
        iconImageView.image = Asset.icRate5.image
        rateItemView.didRateChange = {[weak self] rateCount in
            if rateCount == 1 {
                self?.iconImageView.image = Asset.icRate1.image
            } else if rateCount == 2 {
                self?.iconImageView.image = Asset.icRate2.image
            } else if rateCount == 3 {
                self?.iconImageView.image = Asset.icRate3.image
            } else if rateCount == 4 {
                self?.iconImageView.image = Asset.icRate4.image
            } else if rateCount == 5 {
                self?.iconImageView.image = Asset.icRate5.image
            }
        }
    }

    @IBAction func didTapSubmit(_ sender: Any) {
        if rateItemView.rateCount < 4 {
            rateView.isHidden = true
            thankyouView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: { [weak self] in
                self?.dismiss(animated: true)
            })
        } else {
            guard let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appId)?mt=8&action=write-review") else {
                return
            }
            UIApplication.shared.open(url)
            UserDefaults.standard.hasUserActionRating = true
            dismiss(animated: true)
        }
    }

    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true)
        UserDefaults.standard.hasUserActionRating = false
    }
}

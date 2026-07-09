//
//  Step3ViewController.swift
//  TemplateiOS
//
//  Created by QueNguyen on 23/12/2023.
//

import UIKit

final class Step3ViewController: UIViewController {
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradienTopView: GradientView!

    override func viewDidLoad() {
        super.viewDidLoad()
        desLabel.text = L10n.TemplateiOS.Intro.des3
        titleLabel.text = L10n.TemplateiOS.Intro.title3
        gradienTopView.layer.cornerRadius = 32
        gradienTopView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}

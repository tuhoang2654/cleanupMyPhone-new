//
//  Step2ViewController.swift
//  TemplateiOS
//
//  Created by QueNguyen on 23/12/2023.
//

import UIKit

final class Step2ViewController: UIViewController {
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradienTopView: GradientView!

    override func viewDidLoad() {
        super.viewDidLoad()
        desLabel.text = L10n.TemplateiOS.Intro.des2
        titleLabel.text = L10n.TemplateiOS.Intro.title2
        gradienTopView.layer.cornerRadius = 32
        gradienTopView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

    }
}


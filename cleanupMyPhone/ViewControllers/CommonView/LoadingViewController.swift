//
//  LoadingViewController.swift
//  GPSTracker
//
//  Created by Que Nguyen on 05/08/2023.
//

import UIKit
import Lottie

class LoadingViewController: UIViewController {
    @IBOutlet weak var animationContentView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!

    var animationView: LottieAnimationView!
    var isHiddenText: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView = LottieAnimationView(name: "loading_animation", bundle: Bundle.main)
        animationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.5
        animationContentView.addSubview(animationView)
        loadingLabel.text = "Loading..."
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationView.play()
        loadingLabel.isHidden = isHiddenText
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animationView.stop()
    }
}

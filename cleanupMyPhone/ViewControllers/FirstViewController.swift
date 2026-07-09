//
//  ViewController.swift
//  TemplateiOS5
//
//  Created by Que Nguyen on 22/10/2023.
//

import UIKit
import Lottie

class FirstViewController: UIViewController {
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.5
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationView.play()
        titleLabel.text = L10n.TemplateiOS.Splash.title
        loadingLabel.text = L10n.TemplateiOS.Splash.loading
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            if UserDefaults.standard.firstInstall {
                self.goToLanguage()
            } else {
                let introVC = IntroductionViewController.loadFromNib()
                self.navigationController?.pushViewController(introVC, animated: true)
            }
        }
    }
    
    func goToLanguage() {
        if let languageVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: LanguageViewController.className) as? LanguageViewController {
            navigationController?.pushViewController(languageVC, animated: true)
        }
    }
}


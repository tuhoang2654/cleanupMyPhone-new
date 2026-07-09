//
//  IntroductionViewController.swift
//  TemplateiOS
//
//  Created by QueNguyen on 23/12/2023.
//

import UIKit
import CHIPageControl

final class IntroductionViewController: NativeIntroAdsViewController {
    @IBOutlet weak var pageContentView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: CHIPageControlJalapeno!
    @IBOutlet weak var gradientContainerView: UIView!
    @IBOutlet weak var containerAdsView: UIView!

    var pageViewController: UIPageViewController!
    var isReadySetup: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.numberOfPages = 3
        pageControl.tintColor = UIColor(hex: "#ADB2C5")
        pageControl.currentPageTintColor = UIColor(hex: "#FFAD32")
        pageControl.padding = 8
        pageControl.radius = 5
        nextButton.setTitle(L10n.TemplateiOS.Intro.Button.next, for: .normal)
        navigationController?.setNavigationBarHidden(true, animated: true)
        if UserDefaults.standard.firstInstall {
            configAds(id1: AdsId.native_intro_1, id2: AdsId.native_intro_2, id3: AdsId.native_intro_3, position: .bottom)
        } else {
            configAds(id1: AdsId.native_intro_1_2nd, id2: AdsId.native_intro_2_2nd, id3: AdsId.native_intro_3_2nd, position: .bottom)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPageViewController()
    }

    override func didFailToReceiveAd() {
        heightPlaceHolder.constant = 1
        containerAdsView.alpha = 0
    }
    
    override func didReceiveAd() {
        containerAdsView.alpha = 1
        heightPlaceHolder.constant = 310
    }
    
    private func setupPageViewController() {
        if !isReadySetup {
            pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            pageViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: pageContentView.bounds.size.height)
            pageViewController.delegate = self
            pageViewController.dataSource = self
            let vc = step1Page()
            pageViewController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
            pageContentView.addSubview(pageViewController.view)
            isReadySetup = true
        }
    }

    private func step1Page() -> Step1ViewController {
        return Step1ViewController.loadFromNib()
    }

    private func step2Page() -> Step2ViewController {
        return Step2ViewController.loadFromNib()
    }

    private func step3Page() -> Step3ViewController {
        return Step3ViewController.loadFromNib()
    }

    @IBAction func didTapNext(_ sender: Any) {
        guard let _ = pageViewController.goToNextPage() else {
            goToHome()
            return
        }
        if let index = pageViewController.viewControllers?.first?.view.tag {
            let nexTitle = index == 2 ? L10n.TemplateiOS.Intro.Button.start : L10n.TemplateiOS.Intro.Button.next
            nextButton.setTitle(nexTitle, for: .normal)
            self.pageControl.set(progress: index, animated: true) 
        }
    }
}

extension IntroductionViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if (viewController is Step3ViewController) {
            loadAds(index: 1)
            return step2Page()
        } else if (viewController is Step2ViewController) {
            loadAds(index: 0)
            return step1Page()
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if (viewController is Step1ViewController) {
            loadAds(index: 1)
            return step2Page()
        } else if (viewController is Step2ViewController) {
            loadAds(index: 2)
            return step3Page()
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (!completed)
          {
            return
          }
        let nexTitle = pageViewController.viewControllers!.first!.view.tag == 2 ? L10n.TemplateiOS.Intro.Button.start : L10n.TemplateiOS.Intro.Button.next
        nextButton.setTitle(nexTitle, for: .normal)
        self.pageControl.set(progress: pageViewController.viewControllers!.first!.view.tag, animated: true)
    }
}

extension UIPageViewController {

    func goToNextPage() -> UIViewController? {
       guard let currentViewController = self.viewControllers?.first else { return nil }
       guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return nil }
       setViewControllers([nextViewController], direction: .forward, animated: false, completion: nil)
        return nextViewController
    }

    func goToPreviousPage() {
       guard let currentViewController = self.viewControllers?.first else { return }
       guard let previousViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) else { return }
       setViewControllers([previousViewController], direction: .reverse, animated: false, completion: nil)
    }
}

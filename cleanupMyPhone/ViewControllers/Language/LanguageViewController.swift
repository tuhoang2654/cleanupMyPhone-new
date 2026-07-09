//
//  LanguageViewController.swift
//  DeviceFinder5
//
//  Created by Que Nguyen on 22/10/2023.
//

import UIKit
import SnapKit

final class LanguageViewController: BaseNativeAdvanceAdsViewController, NavigationBaseProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerAds: UIView!
    @IBOutlet weak var navigationCustom: NavigationCustomView!

    var selecting: Bool = false
    var listLanguage: [LanguageModel] = []
    var itemSeleted: LanguageModel?
    var defaultList: [LanguageModel] {
        [LanguageModel(id: 0, icon: Asset.icEnglish.image, title: L10n.TemplateiOS.Language.en, code: "en", isSelected: false),
         LanguageModel(id: 1, icon: Asset.icHindi.image, title: L10n.TemplateiOS.Language.hindi, code: "hi", isSelected: false),
         LanguageModel(id: 2, icon: Asset.icChina.image, title: L10n.TemplateiOS.Language.china, code: "zh-Hans", isSelected: false),
         LanguageModel(id: 3, icon: Asset.icFrance.image, title: L10n.TemplateiOS.Language.french, code: "fr", isSelected: false),
         LanguageModel(id: 4, icon: Asset.icIndonesia.image, title: L10n.TemplateiOS.Language.indonesia, code: "id", isSelected: false),
         LanguageModel(id: 5, icon: Asset.icGermany.image, title: L10n.TemplateiOS.Language.germany, code: "de", isSelected: false)]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.TemplateiOS.Language.title
        let isHiddenLeftButton = UserDefaults.standard.firstInstall
        setupBaseNavigation(isHiddenLeftButton: isHiddenLeftButton)
        tableView.register(UINib(nibName: LanguageItemCell.className, bundle: nil), forCellReuseIdentifier: LanguageItemCell.className)
        preloadData()
        setupNavigationBar()

        if UserDefaults.standard.firstInstall {
            configAds(id: AdsId.native_language, isEnabled: Utils.configAds.enable_native_language, position: .bottom)
        } else {
            configAds(id: AdsId.native_language3, isEnabled: Utils.configAds.enable_native_language_1, position: .bottom)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }

    func setupNavigationBar() {
        navigationCustom.config(title: L10n.TemplateiOS.Language.title, subTitle: L10n.TemplateiOS.Language.des)
        navigationCustom.isEnableRightIcon = UserDefaults.standard.currentLanguage != nil
        navigationCustom.didTapRightBarButton = {[weak self] in
            self?.handleDidTapRightButton()
        }
    }

    func handleDidTapRightButton() {
        if let code = listLanguage.first(where: { $0.isSelected })?.code {
            changeLanguage(to: code)
        }
        if UserDefaults.standard.firstInstall {
            let introVC = IntroductionViewController.loadFromNib()
            self.navigationController?.pushViewController(introVC, animated: true)
            return
        }
        navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveAd() {
        containerAds.alpha = 1
    }
    
    override func didFailToReceiveAd() {
        containerAds.alpha = 0
    }
    
    override func didTapLeftButton() {
        if !UserDefaults.standard.firstInstall {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func preloadData() {
        let currentCode = UserDefaults.standard.currentLanguage
        var tempList: [LanguageModel] = []
        defaultList.forEach { item in
            var tmpItem: LanguageModel = item
            if item.code == currentCode {
                tmpItem.isSelected = true
                itemSeleted = tmpItem
            }
            tempList.append(tmpItem)
        }
        listLanguage = tempList
        tableView.reloadData()
    }

}

extension LanguageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listLanguage.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguageItemCell.className, for: indexPath) as! LanguageItemCell
        cell.config(listLanguage[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !selecting else { return }
        selecting = true
        guard !listLanguage[indexPath.row].isSelected else {
            selecting = false
            return
        }
        var tempList: [LanguageModel] = []
        defaultList.forEach { item in
            var tmpItem: LanguageModel = item
            if item.id == indexPath.row {
                tmpItem.isSelected = true
                itemSeleted = tmpItem
            }
            tempList.append(tmpItem)
        }
        listLanguage = tempList
        tableView.reloadData()
        selecting = false
        navigationCustom.isEnableRightIcon = true
    }
}

struct LanguageModel {
    var id: Int
    var icon: UIImage
    var title: String
    var code: String
    var isSelected: Bool
}

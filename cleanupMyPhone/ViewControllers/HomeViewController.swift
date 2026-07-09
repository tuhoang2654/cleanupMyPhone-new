//
//  HomeViewController.swift
//  TemplateiOS5
//
//  Created by Que Nguyen on 22/10/2023.
//

import Photos
import UIKit

final class HomeViewController: UIViewController {
    @IBOutlet weak var smartCleanButton: UIButton!
    @IBOutlet weak var cleanOldScreenshotButton: UIButton!
    @IBOutlet weak var cleanAlbumButton: UIButton!
    @IBOutlet weak var cleanLargeSizeVideo: UIButton!

    private let photoLibraryService = PhotoLibraryService()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        title = L10n.TemplateiOS.Home.title
    }

    private func setupView() {
        configure(button: smartCleanButton, title: "Smart Clean")
        configure(button: cleanAlbumButton, title: "Clean Album")
        configure(button: cleanOldScreenshotButton, title: "Clean Old Screenshot")
        configure(button: cleanLargeSizeVideo, title: "Clean Large Size Video")
    }

    private func configure(button: UIButton, title: String) {
        button.backgroundColor = .blue
        button.setTitle(title, for: .normal)
    }

    @IBAction func smartCleanBtnClicked(_ sender: Any) {
        requestPhotoAccess { [weak self] in
            self?.pushSmartClean()
        }
    }

    @IBAction func cleanAlbumBtnClicked(_ sender: Any) {
        requestPhotoAccess { [weak self] in
            self?.showDuplicatePhotos()
        }
    }

    @IBAction func cleanOldScreenshotBtnClicked(_ sender: Any) {
        requestPhotoAccess { [weak self] in
            self?.showOldScreenshots()
        }
    }

    @IBAction func cleanLargeSizeVideoBtnClicked(_ sender: Any) {
        requestPhotoAccess { [weak self] in
            self?.showLargeVideos()
        }
    }

    private func requestPhotoAccess(onAuthorized: @escaping () -> Void) {
        photoLibraryService.requestReadWriteAccess { [weak self] isAuthorized in
            guard isAuthorized else {
                self?.showForceAlert(message: "Bạn cần cấp quyền truy cập thư viện ảnh để sử dụng tính năng này.")
                return
            }

            onAuthorized()
        }
    }

    private func pushSmartClean() {
        let viewController = smartCleanViewController(nibName: "smartCleanViewController", bundle: nil)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showDuplicatePhotos() {
        photoLibraryService.fetchImages { [weak self] assets in
            guard let self = self else { return }

            let groupedDuplicates = self.photoLibraryService.findDuplicatesByMetadata(assets: assets)
            guard !groupedDuplicates.isEmpty else {
                self.showForceAlert(message: "Không có ảnh trùng lặp nào.")
                return
            }

            let viewController = GroupDuplicateViewController(nibName: "GroupDuplicateViewController", bundle: nil)
            viewController.groupedDuplicates = groupedDuplicates
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func showOldScreenshots() {
        photoLibraryService.fetchScreenshots { [weak self] screenshots in
            guard let self = self else { return }

            guard !screenshots.isEmpty else {
                self.showForceAlert(message: "Không tìm thấy screenshot nào trong thư viện ảnh.")
                return
            }

            let viewController = cleanOldScreenshotViewController(
                nibName: "cleanOldScreenshotViewController",
                bundle: nil
            )
            viewController.allScreenshots = screenshots
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func showLargeVideos() {
        photoLibraryService.fetchVideos { [weak self] videos in
            guard let self = self else { return }

            guard !videos.isEmpty else {
                self.showForceAlert(message: "Không tìm thấy video nào trong thư viện ảnh.")
                return
            }

            let viewController = cleanLargeSizeVideoViewController(
                nibName: "cleanLargeSizeVideoViewController",
                bundle: nil
            )
            viewController.allVideos = videos
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

// MARK: - Global Navigation Helper

func goToHome() {
    if #available(iOS 15, *) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else { return }
        let homeVC = HomeViewController.loadFromNib()
        let nav = UINavigationController(rootViewController: homeVC)
        delegate.window?.rootViewController = nav
        delegate.window?.makeKeyAndVisible()
    } else {
        guard let window = UIApplication.shared.windows.first else { return }
        let homeVC = HomeViewController.loadFromNib()
        let nav = UINavigationController(rootViewController: homeVC)
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
}

import Photos
import UIKit

class smartCleanViewController: UIViewController {
    @IBOutlet weak var scanningContainerView: UIView!
    @IBOutlet weak var scanningIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scanningStatusLabel: UILabel!
    @IBOutlet weak var scanningProgressView: UIProgressView!

    @IBOutlet weak var resultsContainerView: UIScrollView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var duplicateCardView: UIView!
    @IBOutlet weak var duplicateCountLabel: UILabel!
    @IBOutlet weak var duplicateIncludeSwitch: UISwitch!
    @IBOutlet weak var duplicateDetailButton: UIButton!
    @IBOutlet weak var screenshotCardView: UIView!
    @IBOutlet weak var screenshotCountLabel: UILabel!
    @IBOutlet weak var screenshotIncludeSwitch: UISwitch!
    @IBOutlet weak var screenshotDetailButton: UIButton!
    @IBOutlet weak var emptyStateLabel: UILabel!

    @IBOutlet weak var rescanButton: UIButton!
    @IBOutlet weak var cleanButton: UIButton!

    private let oldScreenshotDayThreshold = 30
    private let smartCleanService = SmartCleanService()
    private let photoLibraryService = PhotoLibraryService()

    private var scanResult: SmartCleanResult?
    private var isScanning = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Smart Clean"
        resultsContainerView.isHidden = true
        startScan()
    }

    private func startScan() {
        guard !isScanning else { return }
        isScanning = true
        showScanningState()

        smartCleanService.scan(
            oldScreenshotDayThreshold: oldScreenshotDayThreshold,
            progress: { [weak self] progress in
                self?.scanningProgressView.progress = progress
            },
            completion: { [weak self] result in
                self?.finishScan(with: result)
            }
        )
    }

    private func showScanningState() {
        scanningContainerView.isHidden = false
        resultsContainerView.isHidden = true
        scanningIndicator.startAnimating()
        scanningProgressView.progress = 0
        scanningStatusLabel.text = "Đang quét thư viện ảnh..."
    }

    private func finishScan(with result: SmartCleanResult) {
        scanResult = result
        isScanning = false

        scanningIndicator.stopAnimating()
        scanningContainerView.isHidden = true
        resultsContainerView.isHidden = false
        updateResultsUI()
    }

    private func updateResultsUI() {
        guard let result = scanResult else { return }

        summaryLabel.text = "Tìm thấy \(result.totalCleanableCount) mục có thể dọn dẹp"
        updateDuplicateCard(with: result)
        updateScreenshotCard(with: result)

        let isEmpty = result.totalCleanableCount == 0
        emptyStateLabel.isHidden = !isEmpty
        cleanButton.isEnabled = !isEmpty
        cleanButton.alpha = isEmpty ? 0.5 : 1.0
        updateCleanButtonTitle()
    }

    private func updateDuplicateCard(with result: SmartCleanResult) {
        let count = result.deletableDuplicates.count

        duplicateCountLabel.text = count > 0
            ? "\(count) ảnh trùng (giữ lại ảnh mới nhất mỗi nhóm)"
            : "Không có ảnh trùng lặp"
        duplicateCardView.isHidden = count == 0
        duplicateIncludeSwitch.isOn = count > 0
        duplicateIncludeSwitch.isEnabled = count > 0
        duplicateDetailButton.isEnabled = count > 0
    }

    private func updateScreenshotCard(with result: SmartCleanResult) {
        let count = result.oldScreenshots.count

        screenshotCountLabel.text = count > 0
            ? "\(count) screenshot cũ hơn \(oldScreenshotDayThreshold) ngày"
            : "Không có screenshot cũ"
        screenshotCardView.isHidden = count == 0
        screenshotIncludeSwitch.isOn = count > 0
        screenshotIncludeSwitch.isEnabled = count > 0
        screenshotDetailButton.isEnabled = count > 0
    }

    private func selectedAssetsToDelete() -> [PHAsset] {
        guard let result = scanResult else { return [] }

        var assets: [PHAsset] = []
        if duplicateIncludeSwitch.isOn {
            assets.append(contentsOf: result.deletableDuplicates)
        }
        if screenshotIncludeSwitch.isOn {
            assets.append(contentsOf: result.oldScreenshots)
        }
        return assets
    }

    private func updateCleanButtonTitle() {
        let count = selectedAssetsToDelete().count
        var config = cleanButton.configuration ?? UIButton.Configuration.filled()
        config.title = count > 0 ? "Dọn dẹp (\(count))" : "Dọn dẹp"
        cleanButton.configuration = config
        cleanButton.isEnabled = count > 0
        cleanButton.alpha = count > 0 ? 1.0 : 0.5
    }

    @IBAction func categorySwitchChanged(_ sender: UISwitch) {
        updateCleanButtonTitle()
    }

    @IBAction func duplicateDetailTapped(_ sender: UIButton) {
        guard let result = scanResult, !result.groupedDuplicates.isEmpty else { return }

        let viewController = GroupDuplicateViewController(nibName: "GroupDuplicateViewController", bundle: nil)
        viewController.groupedDuplicates = result.groupedDuplicates
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func screenshotDetailTapped(_ sender: UIButton) {
        guard let result = scanResult, !result.allScreenshots.isEmpty else { return }

        let viewController = cleanOldScreenshotViewController(
            nibName: "cleanOldScreenshotViewController",
            bundle: nil
        )
        viewController.allScreenshots = result.allScreenshots
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func rescanTapped(_ sender: UIButton) {
        startScan()
    }

    @IBAction func cleanTapped(_ sender: UIButton) {
        let assetsToDelete = selectedAssetsToDelete()
        guard !assetsToDelete.isEmpty else { return }

        let message = "Bạn có chắc muốn xóa \(assetsToDelete.count) mục đã chọn? Ảnh sẽ bị xóa khỏi thư viện ảnh."
        showConfirmAlert(message: message) { [weak self] in
            self?.performClean(assets: assetsToDelete)
        }
    }

    private func performClean(assets: [PHAsset]) {
        cleanButton.isEnabled = false
        rescanButton.isEnabled = false

        photoLibraryService.deleteAssets(assets) { [weak self] result in
            guard let self = self else { return }
            self.rescanButton.isEnabled = true

            switch result {
            case .success:
                self.showForceAlert(message: "Đã dọn dẹp thành công \(assets.count) mục.") {
                    self.startScan()
                }
            case .failure(let error):
                self.cleanButton.isEnabled = true
                let message = error.localizedDescription.isEmpty
                    ? "Không thể xóa. Vui lòng thử lại."
                    : error.localizedDescription
                self.showErrorAlert(message: message)
                self.updateCleanButtonTitle()
            }
        }
    }
}

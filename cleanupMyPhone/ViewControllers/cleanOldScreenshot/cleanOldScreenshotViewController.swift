import Photos
import UIKit

class cleanOldScreenshotViewController: UIViewController {
    @IBOutlet weak var ageFilterControl: UISegmentedControl!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var screenshotCollectionView: UICollectionView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    var allScreenshots: [PHAsset] = []

    private let photoLibraryService = PhotoLibraryService()
    private let dataSource = ScreenshotDataSource()
    private let dateLabelHeight: CGFloat = 18

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Screenshot Cũ"
        setupCollectionView()
        applyCurrentFilter()
    }

    private var currentAgeFilter: ScreenshotAgeFilter {
        ScreenshotAgeFilter(rawValue: ageFilterControl.selectedSegmentIndex) ?? .thirtyDays
    }

    private func setupCollectionView() {
        screenshotCollectionView.delegate = dataSource
        screenshotCollectionView.dataSource = dataSource
        dataSource.onSelectionChanged = { [weak self] in self?.updateActionButtonsState() }

        screenshotCollectionView.register(
            UINib(nibName: "GroupDuplicateCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "GroupDuplicateCollectionViewCell"
        )

        configureGridLayout()
    }

    private func configureGridLayout() {
        guard let layout = screenshotCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let padding: CGFloat = 4
        let itemWidth = (UIScreen.main.bounds.width - (padding * 4)) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + dateLabelHeight)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        layout.sectionInset = UIEdgeInsets(top: 8, left: 4, bottom: 24, right: 4)
    }

    private func applyCurrentFilter() {
        dataSource.update(assets: currentAgeFilter.filter(allScreenshots))
        screenshotCollectionView.reloadData()
        updateSummaryAndEmptyState()
        updateActionButtonsState()
    }

    private func updateSummaryAndEmptyState() {
        summaryLabel.text = "Tìm thấy \(dataSource.assets.count) screenshot cũ hơn \(currentAgeFilter.title)"
        emptyStateLabel.isHidden = !dataSource.assets.isEmpty
        screenshotCollectionView.isHidden = dataSource.assets.isEmpty
    }

    private func updateActionButtonsState() {
        let selectedCount = dataSource.selectedAssetIdentifiers.count
        deleteButton.isEnabled = selectedCount > 0
        deleteButton.alpha = selectedCount > 0 ? 1.0 : 0.5

        var deleteConfig = deleteButton.configuration ?? UIButton.Configuration.filled()
        deleteConfig.title = selectedCount > 0 ? "Xóa (\(selectedCount))" : "Xóa"
        deleteButton.configuration = deleteConfig

        let isAllSelected = selectedCount == dataSource.assets.count && !dataSource.assets.isEmpty
        var selectAllConfig = selectAllButton.configuration ?? UIButton.Configuration.gray()
        selectAllConfig.title = isAllSelected ? "Bỏ chọn" : "Chọn tất cả"
        selectAllButton.configuration = selectAllConfig
    }

    @IBAction func ageFilterChanged(_ sender: UISegmentedControl) {
        applyCurrentFilter()
    }

    @IBAction func selectAllButtonTapped(_ sender: UIButton) {
        let shouldSelectAll = dataSource.selectedAssetIdentifiers.count < dataSource.assets.count
        dataSource.setAllSelected(shouldSelectAll)
        screenshotCollectionView.reloadData()
        updateActionButtonsState()
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let assetsToDelete = dataSource.selectedAssets()
        guard !assetsToDelete.isEmpty else { return }

        let message = "Bạn có chắc muốn xóa \(assetsToDelete.count) screenshot đã chọn? Ảnh sẽ bị xóa khỏi thư viện ảnh."
        showConfirmAlert(message: message) { [weak self] in
            self?.performDelete(assets: assetsToDelete)
        }
    }

    private func performDelete(assets: [PHAsset]) {
        photoLibraryService.deleteAssets(assets) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                let deletedIdentifiers = Set(assets.map(\.localIdentifier))
                self.allScreenshots.removeAll { deletedIdentifiers.contains($0.localIdentifier) }
                self.applyCurrentFilter()

                if self.allScreenshots.isEmpty {
                    self.showForceAlert(message: "Đã xóa xong. Không còn screenshot nào trong thư viện.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            case .failure(let error):
                let message = error.localizedDescription.isEmpty
                    ? "Không thể xóa screenshot. Vui lòng thử lại."
                    : error.localizedDescription
                self.showErrorAlert(message: message)
            }
        }
    }
}

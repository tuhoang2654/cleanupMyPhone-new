import Photos
import UIKit

class cleanLargeSizeVideoViewController: UIViewController {
    @IBOutlet weak var sizeFilterControl: UISegmentedControl!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    var allVideos: [PHAsset] = []

    private let photoLibraryService = PhotoLibraryService()
    private let dataSource = LargeVideoDataSource()
    private let infoLabelHeight: CGFloat = 38
    private var allVideoItems: [LargeVideoItem] = []
    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video Dung Lượng Lớn"
        setupCollectionView()
        resolveVideoSizes()
    }

    private var currentSizeFilter: LargeVideoSizeFilter {
        LargeVideoSizeFilter(rawValue: sizeFilterControl.selectedSegmentIndex) ?? .oneHundredMB
    }

    private func setupCollectionView() {
        videoCollectionView.delegate = dataSource
        videoCollectionView.dataSource = dataSource
        videoCollectionView.allowsMultipleSelection = true
        dataSource.onSelectionChanged = { [weak self] in self?.updateActionButtonsState() }

        videoCollectionView.register(
            UINib(nibName: "GroupDuplicateCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "GroupDuplicateCollectionViewCell"
        )

        configureGridLayout()
        updateLoadingState()
        updateActionButtonsState()
    }

    private func configureGridLayout() {
        guard let layout = videoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let padding: CGFloat = 4
        let itemWidth = (UIScreen.main.bounds.width - (padding * 4)) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + infoLabelHeight)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        layout.sectionInset = UIEdgeInsets(top: 8, left: 4, bottom: 24, right: 4)
    }

    private func resolveVideoSizes() {
        photoLibraryService.resolveLargeVideoItems(from: allVideos) { [weak self] items in
            self?.allVideoItems = items
            self?.applyCurrentFilter()
        }
    }

    private func applyCurrentFilter() {
        let filteredItems = allVideoItems.filter { $0.byteSize >= currentSizeFilter.byteThreshold }
        dataSource.update(items: filteredItems)
        videoCollectionView.reloadData()
        updateSummaryAndEmptyState()
        updateActionButtonsState()
    }

    private func updateLoadingState() {
        summaryLabel.text = "Đang quét video trong thư viện..."
        emptyStateLabel.isHidden = true
        videoCollectionView.isHidden = true
    }

    private func updateSummaryAndEmptyState() {
        let totalSize = dataSource.items.reduce(Int64(0)) { $0 + $1.byteSize } // tính tổng size
        let sizeText = byteFormatter.string(fromByteCount: totalSize)

        summaryLabel.text = "Tìm thấy \(dataSource.items.count) video từ \(currentSizeFilter.title) · \(sizeText)"
        emptyStateLabel.isHidden = !dataSource.items.isEmpty
        videoCollectionView.isHidden = dataSource.items.isEmpty
    }

    private func updateActionButtonsState() {
        let selectedCount = dataSource.selectedAssetIdentifiers.count
        deleteButton.isEnabled = selectedCount > 0
        deleteButton.alpha = selectedCount > 0 ? 1.0 : 0.5

        var deleteConfig = deleteButton.configuration ?? UIButton.Configuration.filled()
        deleteConfig.title = selectedCount > 0 ? "Xóa (\(selectedCount))" : "Xóa"
        deleteButton.configuration = deleteConfig

        let isAllSelected = selectedCount == dataSource.items.count && !dataSource.items.isEmpty
        var selectAllConfig = selectAllButton.configuration ?? UIButton.Configuration.gray()
        selectAllConfig.title = isAllSelected ? "Bỏ chọn" : "Chọn tất cả"
        selectAllButton.configuration = selectAllConfig
    }

    @IBAction func sizeFilterChanged(_ sender: UISegmentedControl) {
        applyCurrentFilter()
    }

    @IBAction func selectAllButtonTapped(_ sender: UIButton) {
        let shouldSelectAll = dataSource.selectedAssetIdentifiers.count < dataSource.items.count
        dataSource.setAllSelected(shouldSelectAll)
        videoCollectionView.reloadData()
        updateActionButtonsState()
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let assetsToDelete = dataSource.selectedAssets()
        guard !assetsToDelete.isEmpty else { return }

        let message = "Bạn có chắc muốn xóa \(assetsToDelete.count) video đã chọn? Video sẽ bị xóa khỏi thư viện ảnh."
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
                self.allVideos.removeAll { deletedIdentifiers.contains($0.localIdentifier) }
                self.allVideoItems.removeAll { deletedIdentifiers.contains($0.asset.localIdentifier) }
                self.dataSource.removeAssets(with: deletedIdentifiers)
                self.applyCurrentFilter()

                if self.allVideoItems.isEmpty {
                    self.showForceAlert(message: "Đã xóa xong. Không còn video nào trong thư viện.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            case .failure(let error):
                let message = error.localizedDescription.isEmpty
                    ? "Không thể xóa video. Vui lòng thử lại."
                    : error.localizedDescription
                self.showErrorAlert(message: message)
            }
        }
    }
}

import Photos
import UIKit

class GroupDuplicateViewController: UIViewController {
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var selectAllButton: UIButton!

    var groupedDuplicates: [[PHAsset]] = []

    private let photoLibraryService = PhotoLibraryService()
    private var dataSource: DuplicatePhotoDataSource!
    private let dateLabelHeight: CGFloat = 18

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ảnh Trùng Lặp"
        dataSource = DuplicatePhotoDataSource(groupedDuplicates: groupedDuplicates)
        setupCollectionView()
        updateActionButtonsState()
    }

    private func setupCollectionView() {
        imageCollectionView.delegate = dataSource
        imageCollectionView.dataSource = dataSource
        imageCollectionView.allowsMultipleSelection = true
        dataSource.onSelectionChanged = { [weak self] in self?.updateActionButtonsState() }

        imageCollectionView.register(
            UINib(nibName: "GroupDuplicateCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "GroupDuplicateCollectionViewCell"
        )
        imageCollectionView.register(
            UINib(nibName: "SectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeaderView"
        )

        configureGridLayout()
    }

    private func configureGridLayout() {
        guard let layout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 4
        let itemWidth = (screenWidth - (padding * 4)) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + dateLabelHeight)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        layout.sectionInset = UIEdgeInsets(top: 8, left: 4, bottom: 24, right: 4)
        layout.headerReferenceSize = CGSize(width: screenWidth, height: 40)
    }

    private func updateActionButtonsState() {
        let selectedCount = dataSource.selectedAssetIdentifiers.count
        deleteButton.isEnabled = selectedCount > 0
        deleteButton.alpha = selectedCount > 0 ? 1.0 : 0.5

        var deleteConfig = deleteButton.configuration ?? UIButton.Configuration.filled()
        deleteConfig.title = selectedCount > 0 ? "Xóa (\(selectedCount))" : "Xóa"
        deleteButton.configuration = deleteConfig

        let isAllSelected = selectedCount == dataSource.totalAssetCount && dataSource.totalAssetCount > 0
        var selectAllConfig = selectAllButton.configuration ?? UIButton.Configuration.gray()
        selectAllConfig.title = isAllSelected ? "Bỏ chọn" : "Chọn tất cả"
        selectAllButton.configuration = selectAllConfig
    }

    @IBAction func selectAllButtonTapped(_ sender: UIButton) {
        let shouldSelectAll = dataSource.selectedAssetIdentifiers.count < dataSource.totalAssetCount
        dataSource.setAllSelected(shouldSelectAll)
        imageCollectionView.reloadData()
        updateActionButtonsState()
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let assetsToDelete = dataSource.selectedAssets()
        guard !assetsToDelete.isEmpty else { return }

        let message = "Bạn có chắc muốn xóa \(assetsToDelete.count) ảnh đã chọn? Ảnh sẽ bị xóa khỏi thư viện ảnh."
        showConfirmAlert(message: message) { [weak self] in
            self?.performDelete(assets: assetsToDelete)
        }
    }

    private func performDelete(assets: [PHAsset]) {
        photoLibraryService.deleteAssets(assets) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.dataSource.removeSelectedAssets()
                self.groupedDuplicates = self.dataSource.groupedDuplicates
                self.imageCollectionView.reloadData()
                self.updateActionButtonsState()

                if self.dataSource.isEmpty {
                    self.showForceAlert(message: "Đã xóa xong. Không còn nhóm ảnh trùng lặp nào.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            case .failure(let error):
                let message = error.localizedDescription.isEmpty
                    ? "Không thể xóa ảnh. Vui lòng thử lại."
                    : error.localizedDescription
                self.showErrorAlert(message: message)
            }
        }
    }
}

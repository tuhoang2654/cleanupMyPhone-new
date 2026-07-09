import Photos
import UIKit

final class DuplicatePhotoDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var onSelectionChanged: (() -> Void)?

    private(set) var groupedDuplicates: [[PHAsset]]
    private(set) var selectedAssetIdentifiers = Set<String>()

    private let imageManager = PHCachingImageManager()
    private let thumbnailSize = CGSize(width: 150, height: 150)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy - HH:mm:ss"
        return formatter
    }()

    init(groupedDuplicates: [[PHAsset]]) {
        self.groupedDuplicates = groupedDuplicates
        super.init()
    }

    var totalAssetCount: Int {
        groupedDuplicates.reduce(0) { $0 + $1.count }
    }

    var isEmpty: Bool {
        groupedDuplicates.isEmpty
    }

    func setAllSelected(_ isSelected: Bool) {
        selectedAssetIdentifiers.removeAll()

        guard isSelected else { return }
        for group in groupedDuplicates {
            for asset in group {
                selectedAssetIdentifiers.insert(asset.localIdentifier)
            }
        }
    }

    func selectedAssets() -> [PHAsset] {
        groupedDuplicates
            .flatMap { $0 }
            .filter { selectedAssetIdentifiers.contains($0.localIdentifier) }
    }

    func removeSelectedAssets() {
        groupedDuplicates = groupedDuplicates.map { group in
            group.filter { !selectedAssetIdentifiers.contains($0.localIdentifier) }
        }.filter { $0.count > 1 }

        selectedAssetIdentifiers.removeAll()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        groupedDuplicates.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        groupedDuplicates[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GroupDuplicateCollectionViewCell",
            for: indexPath
        ) as? GroupDuplicateCollectionViewCell else {
            return UICollectionViewCell()
        }

        let asset = groupedDuplicates[indexPath.section][indexPath.item]
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.configure(
            dateText: dateText(for: asset),
            isSelected: selectedAssetIdentifiers.contains(asset.localIdentifier)
        )

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic

        imageManager.requestImage(
            for: asset,
            targetSize: thumbnailSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.resultImageView.image = image
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let identifier = groupedDuplicates[indexPath.section][indexPath.item].localIdentifier

        if selectedAssetIdentifiers.contains(identifier) {
            selectedAssetIdentifiers.remove(identifier)
        } else {
            selectedAssetIdentifiers.insert(identifier)
        }

        collectionView.reloadItems(at: [indexPath])
        onSelectionChanged?()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 8, left: 4, bottom: 24, right: 4)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "SectionHeaderView",
                for: indexPath
              ) as? SectionHeaderView else {
            return UICollectionReusableView()
        }

        headerView.titleLabel.text = headerTitle(for: indexPath.section)
        return headerView
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 40)
    }

    private func dateText(for asset: PHAsset) -> String? {
        guard let creationDate = asset.creationDate else { return nil }
        return dateFormatter.string(from: creationDate)
    }

    private func headerTitle(for section: Int) -> String {
        let group = groupedDuplicates[section]
        let count = group.count

        if let firstAsset = group.first, let creationDate = firstAsset.creationDate {
            return "Nhóm \(section + 1) · \(count) ảnh · \(dateFormatter.string(from: creationDate))"
        }

        return "Nhóm \(section + 1) · \(count) ảnh"
    }
}

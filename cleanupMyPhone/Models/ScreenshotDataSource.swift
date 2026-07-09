import Photos
import UIKit

final class ScreenshotDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    var onSelectionChanged: (() -> Void)?

    private(set) var assets: [PHAsset] = []
    private(set) var selectedAssetIdentifiers = Set<String>()

    private let imageManager = PHCachingImageManager()
    private let thumbnailSize = CGSize(width: 150, height: 150)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy - HH:mm:ss"
        return formatter
    }()

    func update(assets: [PHAsset], keepingValidSelection: Bool = true) {
        self.assets = assets

        if keepingValidSelection {
            let validIdentifiers = Set(assets.map(\.localIdentifier))
            selectedAssetIdentifiers = selectedAssetIdentifiers.intersection(validIdentifiers)
        }
    }

    func setAllSelected(_ isSelected: Bool) {
        selectedAssetIdentifiers = isSelected
            ? Set(assets.map(\.localIdentifier))
            : []
    }

    func selectedAssets() -> [PHAsset] {
        assets.filter { selectedAssetIdentifiers.contains($0.localIdentifier) }
    }

    func clearSelection() {
        selectedAssetIdentifiers.removeAll()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GroupDuplicateCollectionViewCell",
            for: indexPath
        ) as? GroupDuplicateCollectionViewCell else {
            return UICollectionViewCell()
        }

        let asset = assets[indexPath.item]
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
        let identifier = assets[indexPath.item].localIdentifier

        if selectedAssetIdentifiers.contains(identifier) {
            selectedAssetIdentifiers.remove(identifier)
        } else {
            selectedAssetIdentifiers.insert(identifier)
        }

        collectionView.reloadItems(at: [indexPath])
        onSelectionChanged?()
    }

    private func dateText(for asset: PHAsset) -> String? {
        guard let creationDate = asset.creationDate else { return nil }
        return dateFormatter.string(from: creationDate)
    }
}

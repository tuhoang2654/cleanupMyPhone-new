import Photos
import UIKit

final class LargeVideoDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    var onSelectionChanged: (() -> Void)?

    private(set) var items: [LargeVideoItem] = []
    private(set) var selectedAssetIdentifiers = Set<String>()

    private let imageManager = PHCachingImageManager()
    private let thumbnailSize = CGSize(width: 180, height: 180)
    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter
    }()

    func update(items: [LargeVideoItem], keepingValidSelection: Bool = true) {
        self.items = items

        if keepingValidSelection {
            let validIdentifiers = Set(items.map { $0.asset.localIdentifier })
            selectedAssetIdentifiers = selectedAssetIdentifiers.intersection(validIdentifiers)
        }
    }

    func setAllSelected(_ isSelected: Bool) {
        selectedAssetIdentifiers = isSelected
            ? Set(items.map { $0.asset.localIdentifier })
            : []
    }

    func selectedAssets() -> [PHAsset] {
        items.map(\.asset).filter { selectedAssetIdentifiers.contains($0.localIdentifier) }
    }

    func removeAssets(with identifiers: Set<String>) {
        items.removeAll { identifiers.contains($0.asset.localIdentifier) }
        selectedAssetIdentifiers.subtract(identifiers)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GroupDuplicateCollectionViewCell",
            for: indexPath
        ) as? GroupDuplicateCollectionViewCell else {
            return UICollectionViewCell()
        }

        let item = items[indexPath.item]
        let asset = item.asset

        cell.representedAssetIdentifier = asset.localIdentifier
        cell.configure(
            dateText: infoText(for: item),
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
        let identifier = items[indexPath.item].asset.localIdentifier

        if selectedAssetIdentifiers.contains(identifier) {
            selectedAssetIdentifiers.remove(identifier)
        } else {
            selectedAssetIdentifiers.insert(identifier)
        }

        collectionView.reloadItems(at: [indexPath])
        onSelectionChanged?()
    }

    private func infoText(for item: LargeVideoItem) -> String {
        "\(byteFormatter.string(fromByteCount: item.byteSize)) · \(durationText(for: item.asset.duration))"
    }

    private func durationText(for duration: TimeInterval) -> String {
        let totalSeconds = Int(duration.rounded())
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%d:%02d", minutes, seconds)
    }
}

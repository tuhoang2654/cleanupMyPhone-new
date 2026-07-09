import Photos

struct SmartCleanResult {
    let groupedDuplicates: [[PHAsset]]
    let deletableDuplicates: [PHAsset]
    let allScreenshots: [PHAsset]
    let oldScreenshots: [PHAsset]

    var totalCleanableCount: Int {
        deletableDuplicates.count + oldScreenshots.count
    }
}

final class SmartCleanService {
    private let photoLibraryService: PhotoLibraryService

    init(photoLibraryService: PhotoLibraryService = PhotoLibraryService()) {
        self.photoLibraryService = photoLibraryService
    }

    func scan(
        oldScreenshotDayThreshold: Int,
        progress: @escaping (Float) -> Void,
        completion: @escaping (SmartCleanResult) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [photoLibraryService] in
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            var photoAssets: [PHAsset] = []
            var screenshots: [PHAsset] = []
            photoAssets.reserveCapacity(allPhotos.count)

            allPhotos.enumerateObjects { asset, index, _ in
                photoAssets.append(asset)
                if asset.mediaSubtypes.contains(.photoScreenshot) {
                    screenshots.append(asset)
                }

                if allPhotos.count > 0, index % max(allPhotos.count / 10, 1) == 0 {
                    let currentProgress = Float(index + 1) / Float(allPhotos.count)
                    DispatchQueue.main.async { progress(currentProgress) }
                }
            }

            let duplicates = photoLibraryService.findDuplicatesByMetadata(assets: photoAssets)
            let deletable = duplicates.flatMap { Array($0.dropFirst()) }
            let oldScreenshots = Self.filterOldScreenshots(
                screenshots,
                olderThanDays: oldScreenshotDayThreshold
            )

            let result = SmartCleanResult(
                groupedDuplicates: duplicates,
                deletableDuplicates: deletable,
                allScreenshots: screenshots,
                oldScreenshots: oldScreenshots
            )

            DispatchQueue.main.async {
                progress(1)
                completion(result)
            }
        }
    }

    private static func filterOldScreenshots(_ assets: [PHAsset], olderThanDays dayCount: Int) -> [PHAsset] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -dayCount, to: Date()) ?? Date()
        return assets.filter { asset in
            guard let creationDate = asset.creationDate else { return false }
            return creationDate < cutoffDate
        }
    }
}

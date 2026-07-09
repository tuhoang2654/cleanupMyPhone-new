import Photos

enum PhotoLibraryError: Error {
    case accessDenied
}

final class PhotoLibraryService {
    func requestReadWriteAccess(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                completion(status == .authorized || status == .limited)
            }
        }
    }

    func fetchImages(completion: @escaping ([PHAsset]) -> Void) {
        fetchAssets(mediaType: .image, completion: completion)
    }

    func fetchScreenshots(completion: @escaping ([PHAsset]) -> Void) {
        fetchImages { assets in
            completion(assets.filter { $0.mediaSubtypes.contains(.photoScreenshot) })
        }
    }

    func fetchVideos(completion: @escaping ([PHAsset]) -> Void) {
        fetchAssets(mediaType: .video, completion: completion)
    }

    func deleteAssets(_ assets: [PHAsset], completion: @escaping (Result<Void, Error>) -> Void) {
        guard !assets.isEmpty else {
            DispatchQueue.main.async { completion(.success(())) }
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(error ?? PhotoLibraryError.accessDenied))
                }
            }
        })
    }

    func findDuplicatesByMetadata(assets: [PHAsset]) -> [[PHAsset]] {
        var groups: [[PHAsset]] = []
        var checkedIdentifiers = Set<String>()

        for index in assets.indices {
            let assetA = assets[index]
            if checkedIdentifiers.contains(assetA.localIdentifier) { continue }

            var currentGroup = [assetA]
            guard let dateA = assetA.creationDate else { continue }

            for nextIndex in assets.index(after: index)..<assets.count {
                let assetB = assets[nextIndex]
                if checkedIdentifiers.contains(assetB.localIdentifier) { continue }
                guard let dateB = assetB.creationDate else { continue }

                let timeDifference = abs(dateA.timeIntervalSince(dateB))
                if timeDifference > 3 { break }

                if assetA.pixelWidth == assetB.pixelWidth && assetA.pixelHeight == assetB.pixelHeight {
                    currentGroup.append(assetB)
                }
            }

            if currentGroup.count > 1 {
                groups.append(currentGroup)
                currentGroup.forEach { checkedIdentifiers.insert($0.localIdentifier) }
            }
        }

        return groups
    }

    func resolveLargeVideoItems(from assets: [PHAsset], completion: @escaping ([LargeVideoItem]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let items = assets.compactMap { asset -> LargeVideoItem? in
                guard let byteSize = Self.fileSize(for: asset), byteSize > 0 else { return nil }
                return LargeVideoItem(asset: asset, byteSize: byteSize)
            }.sorted { $0.byteSize > $1.byteSize }

            DispatchQueue.main.async {
                completion(items)
            }
        }
    }

    private func fetchAssets(mediaType: PHAssetMediaType, completion: @escaping ([PHAsset]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            let result = PHAsset.fetchAssets(with: mediaType, options: fetchOptions)
            var assets: [PHAsset] = []
            assets.reserveCapacity(result.count)
            result.enumerateObjects { asset, _, _ in assets.append(asset) }

            DispatchQueue.main.async {
                completion(assets)
            }
        }
    }

    private static func fileSize(for asset: PHAsset) -> Int64? {
        let totalSize = PHAssetResource.assetResources(for: asset).reduce(Int64(0)) { result, resource in
            let fileSize = resource.value(forKey: "fileSize") as? Int64
                ?? (resource.value(forKey: "fileSize") as? CLong).map(Int64.init)
                ?? 0
            return result + fileSize
        }

        return totalSize > 0 ? totalSize : nil
    }
}

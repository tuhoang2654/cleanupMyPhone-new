import Foundation
import Photos

enum ScreenshotAgeFilter: Int {
    case thirtyDays = 0
    case threeMonths = 1
    case sixMonths = 2
    case oneYear = 3

    var dayCount: Int {
        switch self {
        case .thirtyDays: return 30
        case .threeMonths: return 90
        case .sixMonths: return 180
        case .oneYear: return 365
        }
    }

    var title: String {
        switch self {
        case .thirtyDays: return "30 ngày"
        case .threeMonths: return "3 tháng"
        case .sixMonths: return "6 tháng"
        case .oneYear: return "1 năm"
        }
    }

    func filter(_ assets: [PHAsset]) -> [PHAsset] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -dayCount, to: Date()) ?? Date()
        return assets.filter { asset in
            guard let creationDate = asset.creationDate else { return false }
            return creationDate < cutoffDate
        }
    }
}

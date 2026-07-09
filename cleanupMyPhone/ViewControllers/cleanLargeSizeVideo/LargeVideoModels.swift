import Photos

struct LargeVideoItem {
    let asset: PHAsset
    let byteSize: Int64
}

enum LargeVideoSizeFilter: Int {
    case oneHundredMB = 0
    case fiveHundredMB = 1
    case oneGB = 2

    var byteThreshold: Int64 {
        switch self {
        case .oneHundredMB: return 100 * 1024 * 1024
        case .fiveHundredMB: return 500 * 1024 * 1024
        case .oneGB: return 1024 * 1024 * 1024
        }
    }

    var title: String {
        switch self {
        case .oneHundredMB: return "100 MB"
        case .fiveHundredMB: return "500 MB"
        case .oneGB: return "1 GB"
        }
    }
}

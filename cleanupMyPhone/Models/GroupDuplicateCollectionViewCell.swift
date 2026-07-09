//
//  GroupDuplicateCollectionViewCell.swift
//  cleanupMyPhone
//
//  Created by Hoàng Anh Tú on 1/7/26.
//

import UIKit

class GroupDuplicateCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectionOverlay: UIView!
    @IBOutlet weak var checkmarkView: UIImageView!

    /// Dùng để tránh gán nhầm ảnh khi cell được tái sử dụng trước khi request cũ hoàn tất
    var representedAssetIdentifier: String?

    var isAssetSelected = false {
        didSet { updateSelectionAppearance() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor

        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        checkmarkView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
    }

    func configure(dateText: String?, isSelected: Bool) {
        dateLabel.text = dateText ?? "Không rõ thời gian"
        isAssetSelected = isSelected
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        representedAssetIdentifier = nil
        resultImageView.image = nil
        dateLabel.text = nil
        isAssetSelected = false
    }

    private func updateSelectionAppearance() {
        selectionOverlay.isHidden = !isAssetSelected
        checkmarkView.isHidden = !isAssetSelected
        contentView.layer.borderColor = isAssetSelected
            ? UIColor.systemBlue.cgColor
            : UIColor.separator.cgColor
        contentView.layer.borderWidth = isAssetSelected ? 2 : 0.5
    }
}

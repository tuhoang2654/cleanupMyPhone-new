//
//  LanguageItemCell.swift
//  DeviceFinder5
//
//  Created by Que Nguyen on 25/10/2023.
//

import UIKit

final class LanguageItemCell: UITableViewCell {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var checkImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupDrowShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ item: LanguageModel) {
        logoImageView.image = item.icon
        titleLabel.text = item.title
        checkImage.image = item.isSelected ? Asset.icRadioSelected.image : Asset.icRadioNormal.image
    }
    
    private func setupDrowShadow() {
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor(red: 39/255, green: 49/255, blue: 114/255, alpha: 0.25).cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shadowRadius = 3.0
    }
}

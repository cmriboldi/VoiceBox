//
//  WordCell.swift
//  VoiceBox
//
//  Created by Andrew Hale on 2/26/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

class WordCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 10 : 0
        }
    }
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
//        imageView.layer.borderColor = themeColor.cgColor
        isSelected = false
    }
}

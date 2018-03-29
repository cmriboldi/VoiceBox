//
//  WordCell.swift
//  VoiceBox
//
//  Created by Andrew Hale on 2/26/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

class WordCell: UICollectionViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var wordView: RoundedButton?
    let borderOffset: CGFloat = 10.0
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.subviews.forEach({ $0.removeFromSuperview() })
        wordView = RoundedButton.init(frame: CGRect.init(x: self.frame.minX + borderOffset, y: self.frame.minY + borderOffset, width: self.frame.width - borderOffset*2, height: self.frame.height - borderOffset*2), image: nil, needsBorder: true)
        self.addSubview(wordView!)
    }
}

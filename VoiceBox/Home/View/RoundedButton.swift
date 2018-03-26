//
//  RoundedButton.swift
//  VoiceBox
//
//  Created by Andrew Hale on 2/10/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit
import IBAnimatable

@IBDesignable class RoundedButton: AnimatableView {

//    @IBOutlet weak var wordLabel: UITextView!
//
    struct Constants {
        static let labelHeight: CGFloat = 40
        static let labelTopOffset: CGFloat = 5
        static let labelWidthOffset: CGFloat = 20
        static let imageOffset: CGFloat = 5
        
    }
    var wordLabel = UILabel(frame:CGRect.zero)
    var wordImage = UIImageView(frame:CGRect.zero)
    var index: Int!
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.frame = CGRect.init(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        wordImage = UIImageView(frame: CGRect.init(x: 0.0, y: Constants.imageOffset, width: frame.width, height: frame.height-Constants.labelHeight))
        wordLabel = UILabel(frame: CGRect.init(x: 0.0, y: frame.height-Constants.labelHeight-Constants.labelTopOffset, width: frame.width-Constants.labelWidthOffset, height: Constants.labelHeight))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let margins = self.layoutMarginsGuide
        
        // configure image layout
        wordImage.image = #imageLiteral(resourceName: "smiley_face")
        wordImage.contentMode = .scaleAspectFit
        wordImage.backgroundColor = UIColor.white
        wordImage.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
        wordImage.topAnchor.constraint(equalTo: margins.topAnchor)
        wordImage.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        wordImage.bottomAnchor.constraint(equalTo: wordLabel.topAnchor)
        
        // configure label layout
        wordLabel.backgroundColor = UIColor.white
        wordLabel.textAlignment = .center
        wordLabel.font = UIFont.systemFont(ofSize: 30.0, weight: .bold)
        wordLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
        wordLabel.topAnchor.constraint(equalTo: wordImage.bottomAnchor)
        wordLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        wordLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.adjustsFontSizeToFitWidth = true

        // configure border layout.
        self.cornerRadius = 0.15 * bounds.size.width
        self.backgroundColor = UIColor.white
        self.borderColor = UIColor.black
        self.borderWidth = 2
        self.clipsToBounds = true

        self.addSubview(wordLabel)
        self.addSubview(wordImage)
        
        //center image
        let centerXConst = NSLayoutConstraint(item: wordLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: wordLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: wordLabel, attribute: .top, relatedBy: .equal, toItem: wordImage, attribute: .bottom, multiplier: 1.0, constant: -5.0)
        
        let widthConstraint = NSLayoutConstraint(item: wordLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.frame.width - Constants.labelWidthOffset)
        wordLabel.addConstraints([widthConstraint])
        
        NSLayoutConstraint.activate([centerXConst, bottomConstraint, topConstraint])
    }
    
    func setTitle(_ title: String) {
        self.wordLabel.text = title
    }
    
}

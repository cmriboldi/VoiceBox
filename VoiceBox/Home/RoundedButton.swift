//
//  RoundedButton.swift
//  VoiceBox
//
//  Created by Andrew Hale on 2/10/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

@IBDesignable class RoundButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        // Common logic goes here
        refreshCorners(value: cornerRadius)
    }
    
    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = 0.5 * bounds.size.width
        backgroundColor = .clear
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
        clipsToBounds = true
    }
}

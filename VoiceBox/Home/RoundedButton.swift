//
//  RoundedButton.swift
//  VoiceBox
//
//  Created by Andrew Hale on 2/10/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit
import IBAnimatable

@IBDesignable class RoundButton: AnimatableButton {
    
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
        self.cornerRadius = 0.5 * bounds.size.width
        self.backgroundColor = UIColor.white
        self.borderColor = UIColor.black
        self.borderWidth = 2
        self.clipsToBounds = true
    }
}

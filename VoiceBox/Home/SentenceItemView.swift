//
//  SentenceItemView.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 10/17/17.
//  Copyright © 2017 Christian Riboldi. All rights reserved.
//

import UIKit

class SentenceItemView : VocabItemView {
    
    override func draw(_ rect: CGRect) {
        drawImage()
        drawWord()
    }
    
}


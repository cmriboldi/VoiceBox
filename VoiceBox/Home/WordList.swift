//
//  WordList.swift
//  VoiceBox
//
//  Created by Andrew Hale on 1/22/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

class WordList: UIStackView {
    //MARK: Initialization
    var words = [String]()
    
    var wordLabels = [UILabel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWords()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupWords()
    }
    
    public func setupWords() {
        // clear any existing buttons
        for label in wordLabels {
            removeArrangedSubview(label)
            label.removeFromSuperview()
        }
        wordLabels.removeAll()
        
        for i in 0..<words.count {
            // Create the button
            let label = UILabel()
            label.text = words[i]
            
            // Add the button to the stack
            addArrangedSubview(label)
            
            // Add the new button to the rating button array
            wordLabels.append(label)
        }
    }
}

//
//  VocabItemView.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 10/12/17.
//  Copyright © 2017 Christian Riboldi. All rights reserved.
//

import UIKit

@IBDesignable
class VocabItemView: UIView {
    
    // MARK: - Constants
    
    private struct Vocab {
        static let backImageName = "word_button_background"
        static let placeholderImageName = "image_placeholder"
    }
    
    // MARK: - Properties
    
    var word = Word()
    
    // MARK: - Computed properties
    
    @IBInspectable var text: String {
        get {
            return word.value
        }
        set {
            word.value = newValue
        }
    }
    
    @IBInspectable var image: UIImage? {
        get {
            return word.image
        }
    }
    
    @IBInspectable var spokenPhrase: String? {
        get {
            return word.spokenPhrase
        }
    }
    
    @IBInspectable var vocabType: String {
        get {
            return word.type.description
        }
        set {
            if let newType = WordType(rawValue: newValue) {
                word.type = newType
            }
        }
    }
    
    // See slides for explanations of the uses of these computed properties
    
    var centerFontSize       : CGFloat { return bounds.width * 0.55 }
    var centerImageMargin    : CGFloat { return bounds.width * 0.15 }
    var cornerImageWidth     : CGFloat { return bounds.width * 0.18 }
    var cornerRadius         : CGFloat { return bounds.width * 0.05 }
    var centerImageYOffset   : CGFloat { return 6.0 }
    var imageScalingRatio    : CGFloat { return 0.7 }
    var wordTextYOffset      : CGFloat { return 1.45 }
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
        isOpaque = false
    }
    
    //MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        drawBase()
        drawImage()
        drawWord()
    }
    
    func drawBase() {
        switch vocabType {
        case WordType.word.description:
            drawButtonBackground()
        case WordType.folder.description:
            drawFolderBackground()
        default:
            drawButtonBackground()
        }
    }
    
    func drawButtonBackground() {
        if let backgroundImage = UIImage(named: Vocab.backImageName + "_\(word.buttonColor)") {
            backgroundImage.draw(in: bounds)
        }
    }
    
    func drawFolderBackground() {
        //TODO: I need to draw the icon for folders.
    }
    
    func drawImage() {
        guard let wordImage = word.image else {
            return
        }
        
        let imageSideWidth = bounds.width * imageScalingRatio
        let wordImageRect = CGRect(x: centerImageMargin,
                                   y: centerImageYOffset,
                                   width: imageSideWidth,
                                   height: imageSideWidth)
        
        wordImage.draw(in: wordImageRect)
    }
    
    func drawWord() {
        let wordText = word.value
        var textBounds = CGRect.zero
        
        textBounds.size = wordText.size()
        textBounds.origin = CGPoint(x: (bounds.width - textBounds.width) / 2,
                                    y: bounds.height - textBounds.height * wordTextYOffset)
        wordText.draw(in: textBounds)
    }
    
    func popContext() {
        UIGraphicsGetCurrentContext()?.restoreGState()
    }
    
    func pushContext() -> CGContext? {
        let context = UIGraphicsGetCurrentContext()
        
        context?.saveGState()
        
        return context
    }
    
    
}



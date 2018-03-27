//
//  SearchButton.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 3/27/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit
import IBAnimatable

class SearchButton: AnimatableView {

    struct Constants {
        static let imageOffset: CGFloat = 30
        static let imageSizeScale: CGFloat = 0.4
    }
    var searchImage = UIImageView(frame:CGRect.zero)
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.frame = CGRect.init(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        let imageWidth = frame.width * Constants.imageSizeScale
        let imageHeight = frame.height * Constants.imageSizeScale
        searchImage = UIImageView(frame: CGRect.init(x: frame.width/2 - imageWidth/2, y: frame.height/2 - imageHeight/2, width: imageWidth, height: imageHeight))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let margins = self.layoutMarginsGuide
        
        // configure image layout
        searchImage.image = #imageLiteral(resourceName: "ic_search")
        searchImage.contentMode = .scaleAspectFit
        searchImage.backgroundColor = UIColor.white
        searchImage.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
        searchImage.topAnchor.constraint(equalTo: margins.topAnchor)
        searchImage.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        searchImage.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        
        // configure border layout.
        self.cornerRadius = 0.15 * bounds.size.width
        self.backgroundColor = UIColor.white
        self.borderColor = UIColor.black
        self.borderWidth = 2
        self.clipsToBounds = true
        
        self.addSubview(searchImage)
    }
}

//
//  String+helpers.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 2/14/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

extension String {
    
    func minimized() -> String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.width)
    }
    
    func getFontSize(withConstrainedWidth width: CGFloat, withFont font: UIFont) -> CGFloat {
        var fontSize: CGFloat = 1.0
        let height: CGFloat = self.height(withConstrainedWidth: width, font: font.withSize(37.0))
        let startingWidth = self.width(withConstrainedHeight: height, font: font.withSize(37.0))
        var width: CGFloat = startingWidth
        while width <= startingWidth {
            fontSize += 1.0
            width = self.width(withConstrainedHeight: height, font: font.withSize(fontSize))
        }
        return fontSize - 1
    }
}

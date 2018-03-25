//
//  Node.swift
//  VoiceBox
//
//  Created by Andrew Hale on 2/23/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class Node {
    var name: String
    var imageName: String
    var image: UIImage?

    required init(name: String = "", imageName: String = "", image: UIImage? = nil) {
        self.name = name
        self.imageName = imageName
        self.image = image
    }
    
    required init(node: Node) {
        self.name = node.name
        self.imageName = node.imageName
        self.image = node.image
    }
    
    func getChildren() -> [Node]? {return nil}
    func addChild(child: Node, parentName: String){}
    func findWord(word: String, parent: String) -> String {return ""}
    func getWords(words: inout [String]) {}
    func getNodes(parentName: String, nodes: inout [Node]) {}
    func getType() -> String {return ""}
    
    func getName() -> String {
        return self.name
    }
    
    func getImageSize() -> CGSize {
        return CGSize(width: 200, height: 200)
    }
    
    func setImageName(imageName: String) {
        self.imageName = imageName
    }
    
    func createImage(size: CGSize) -> UIImage {
        let word = self.name
        let baseSize = word.boundingRect(with: CGSize(width: 2048, height: 2048), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: size.height / 2)], context: nil).size
        let fontSize = size.width / max(baseSize.width, baseSize.height) * (size.width / 2)
        let font = UIFont.systemFont(ofSize: fontSize)
        let textSize = word.boundingRect(with: CGSize(width: size.width, height: size.height), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        style.lineBreakMode = NSLineBreakMode.byClipping
        
        let attr: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: font, NSAttributedStringKey.paragraphStyle: style, NSAttributedStringKey.backgroundColor: UIColor.clear]
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        word.draw(in: CGRect(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2, width: textSize.width, height: textSize.height), withAttributes: attr)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let imageView = UIImageView(image: image)
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.clipsToBounds = true
        if let _ = self as? Folder {imageView.layer.cornerRadius = imageView.bounds.width / 2}
        
        return UIImage(view: imageView)
    }

    func getImage() -> UIImage {
        if self.image == nil {
            if self.imageName != "" {
                self.setImage(image: UIImage(named: self.imageName)!)
            }
            else {
                // Create a reference with an initial file path and name
                let user = Auth.auth().currentUser

                var path = "images/"
                path.append((user?.uid)!)
                path.append("/")
                path.append(self.getType())
                path.append("/")
                path.append(self.name)
                path.append(".png")

                let imageRef = Storage.storage().reference(withPath: path)

                // Download in memory with a maximum allowed size of 50MB (50 * 1024 * 1024 bytes)
                //FIXME: This maxSize might need to be adjusted.
                let _ = imageRef.getData(maxSize: 50 * 1024 * 1024) { (data, error) in
                    if let error = error {}
                    else {self.setImage(image: UIImage(data: data!)!)}
                }
            }
        }
        if self.image == nil {self.setImage(image: self.createImage(size: self.getImageSize()))}
        return self.image!
    }
    
    func setImage(image: UIImage) {
        let size = image.size
        let targetSize = self.getImageSize()
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let _ = self as? Folder {
            let imageView = UIImageView(image: newImage)
            imageView.clipsToBounds = true
            //            imageView.layer.cornerRadius = imageView.bounds.width / 2.5
            imageView.layer.cornerRadius = 50
            newImage = UIImage(view: imageView)
        }
        
        self.image = newImage
    }
}

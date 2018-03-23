//
//  VocabularyWord.swift
//  VoiceBox
//
//  Created by Andrew Hale on 2/23/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation
import UIKit

class VocabularyWord: Node {
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
    
    func getChildren() -> [Node]? {
        return nil
    }
    
    func addChild(child: Node, parentName: String) {}
    
    func findWord(word: String, parent: String) -> String {
        if self.name == word {return self.name}
        return ""
    }
    
    func getWords(words: inout [String]) {
        words.append(self.name)
    }
    
    func getNodes(parentName: String, nodes: inout [Node]) {}
}

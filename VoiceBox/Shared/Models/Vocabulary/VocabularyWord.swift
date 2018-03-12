//
//  VocabularyWord.swift
//  VoiceBox
//
//  Created by Andrew Hale on 2/23/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation

class VocabularyWord: Node {
    var name: String
    var imageName: String
    
    required init(name: String = "", imageName: String = "") {
        self.name = name
        self.imageName = imageName
    }
    
    required init(node: Node) {
        self.name = node.name
        self.imageName = node.imageName
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

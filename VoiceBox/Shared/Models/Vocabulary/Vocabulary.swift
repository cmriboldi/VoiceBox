//
//  Vocabulary.swift
//  VoiceBox
//
//  Created by Andrew Hale on 2/23/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

class Vocabulary: NSObject {
    var root: Folder = Folder(name: "")
    
    func getChildren() -> [Node]? {
        return root.getChildren()
    }
    
    func addChild(child: Node, parentName: String) {
        self.root.addChild(child: child, parentName: parentName)
    }
    
    func findWord(word: String) -> String {
        return self.root.findWord(word: word)
    }
    
    func getAllWords() -> [String] {
        var words = [String]()
        self.root.getWords(words: &words)
        return words
    }
    
    func getNodes(parentName: String) -> [Node] {
        var nodes = [Node]()
        self.root.getNodes(parentName: parentName, nodes: &nodes)
        return nodes
    }
}

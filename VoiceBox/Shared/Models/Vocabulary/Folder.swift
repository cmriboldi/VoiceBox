//
//  Folder.swift
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

class Folder: Node {
    var children: [Node]
    
    required init(name: String = "", imageName: String? = nil, image: UIImage? = nil) {
        self.children = []
        super.init(name: name, imageName: imageName, image: image)
    }
    
    required init(node: Node) {
        self.children = node.getChildren()!
        super.init(node: node)
    }
    
    override func getChildren() -> [Node]? {
        return self.children
    }
    
    override func getName() -> String {
        return self.name
    }

    override func addChild(child: Node, parentName: String) {
        if parentName == self.name {children.append(child)}
        else {for c in self.children {c.addChild(child: child, parentName: parentName)}}
    }
    
    override func findWord(word: String, parent: String) -> String {
        if self.name != parent {
            for c in self.children {
                var foundWord = ""
                if let folder = c as? Folder {foundWord = folder.findWord(word: word, parent: parent)}
                if foundWord != "" {return foundWord}
            }
            return ""
        }
        return self.actualFindWord(word: word, parent: parent)
    }
    
    func actualFindWord(word: String, parent: String) -> String {
        for c in self.children {
            var foundWord = ""
            if let folder = c as? Folder {foundWord = folder.actualFindWord(word: word, parent: parent)}
            else {foundWord = c.findWord(word: word, parent: parent)}
            if foundWord != "" {return foundWord}
        }
        return ""
    }
    
    override func getWords(words: inout [String]) {
        for c in children {c.getWords(words: &words)}
    }
    
    override func getNodes(parentName: String, nodes: inout [Node]) {
        if parentName == self.name {for c in children {nodes.append(c)}}
        else {for c in children {c.getNodes(parentName: parentName, nodes: &nodes)}}
    }
    
    override func getType() -> String {return "Folder"}
}

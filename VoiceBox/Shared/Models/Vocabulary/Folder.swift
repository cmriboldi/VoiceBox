//
//  Folder.swift
//  VoiceBox
//
//  Created by Andrew Hale on 2/23/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation
import UIKit

class Folder: Node {
    var name: String
    var imageName: String
    var children: [Node]
    
    required init(name: String = "", imageName: String = "") {
        self.name = name
        self.imageName = imageName
        self.children = []
    }
    
    required init(node: Node) {
        self.name = node.name
        self.imageName = node.imageName
        self.children = node.getChildren()!
    }
    
    func getChildren() -> [Node]? {
        return self.children
    }
    
    func getName() -> String {
        return self.name
    }

    func addChild(child: Node, parentName: String) {
        if parentName == self.name {children.append(child)}
        else {for c in self.children {c.addChild(child: child, parentName: parentName)}}
    }
    
    func findWord(word: String, parent: String) -> String {
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
    
    func getWords(words: inout [String]) {
        for c in children {c.getWords(words: &words)}
    }
    
    func getNodes(parentName: String, nodes: inout [Node]) {
        if parentName == self.name {for c in children {nodes.append(c)}}
        else {for c in children {c.getNodes(parentName: parentName, nodes: &nodes)}}
    }
}

//
//  Vocabulary.swift
//  VoiceBox
//
//  Created by Andrew Hale on 2/23/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

class Vocabulary: NSObject {
    var root = Folder(name: "")
    var rootLikely = Folder(name: "")
    var rootSearch = Folder(name: "")

    func getChildren() -> [Node]? {
        return root.getChildren()
    }

    func addChild(child: Node, parentName: String, type root: String = "") {
        if root == "likely" {self.rootLikely.addChild(child: child, parentName: parentName)}
        else if root == "search" {self.rootSearch.addChild(child: child, parentName: parentName)}
        else {self.root.addChild(child: child, parentName: parentName)}
    }

    func findWord(word: String, parent: String = "") -> String {
        return self.root.findWord(word: word, parent: parent)
    }

    func getAllWords() -> [String] {
        var words = [String]()
        self.root.getWords(words: &words)
        return words
    }

    func getNodes(parentName: String, search: Bool = false) -> [Node] {
        var nodes = [Node]()
        if search {self.rootSearch.getNodes(parentName: parentName, nodes: &nodes)}
        else {
            self.rootLikely.getNodes(parentName: parentName, nodes: &nodes)
            self.root.getNodes(parentName: parentName, nodes: &nodes)
        }
        return nodes
    }
    
    func clear(type root: String) {
        if root == "likely" {self.rootLikely = Folder(name: "")}
        else if root == "search" {self.rootSearch = Folder(name: "")}
        else {self.root = Folder(name: "")}
    }
}

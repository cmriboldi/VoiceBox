//
//  Node.swift
//  VoiceBox
//
//  Created by Andrew Hale on 2/23/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation
import UIKit

protocol Node {
    var name: String {get}
    var imageName: String {get}

    init(name: String, imageName: String)
    init(node: Node)
    func getChildren() -> [Node]?
    func addChild(child: Node, parentName: String)
    func findWord(word: String, parent: String) -> String
    func getWords(words: inout [String])
    func getNodes(parentName: String, nodes: inout [Node])
}

extension Node {
    func getName() -> String {
        return self.name
    }
    
    func getImageSize() -> CGSize {
        return CGSize(width: 200, height: 200)
    }
}

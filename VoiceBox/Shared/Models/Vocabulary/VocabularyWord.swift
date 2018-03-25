//
//  VocabularyWord.swift
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

class VocabularyWord: Node {
    override func getChildren() -> [Node]? {
        return nil
    }
    
    override func addChild(child: Node, parentName: String) {}
    
    override func findWord(word: String, parent: String) -> String {
        if self.name == word {return self.name}
        return ""
    }
    
    override func getWords(words: inout [String]) {
        words.append(self.name)
    }
    
    override func getNodes(parentName: String, nodes: inout [Node]) {}
    
    override func getType() -> String {return "VocabularyWord"}
}

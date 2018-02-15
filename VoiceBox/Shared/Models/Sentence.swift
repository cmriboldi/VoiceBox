//
//  Sentence.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 10/17/17.
//  Copyright © 2017 Christian Riboldi. All rights reserved.
//

import Foundation

class Sentence {
    private var sentenceWords = [Word]()
    
    var isEmpty: Bool {
        get {
            return sentenceWords.isEmpty
        }
    }
    
    var count: Int {
        get {
            return sentenceWords.count
        }
    }
    
    func removeLast() {
        sentenceWords.removeLast()
    }
    
    func removeAll() {
        sentenceWords.removeAll()
    }
    
    func append(_ word: Word) {
        sentenceWords.append(word)
    }
    
    func getSpokenSentence() -> String {
        var fullSentence = ""
        for word in sentenceWords {
            fullSentence += "\(word.spokenPhrase) "
        }
        print("fullSentence: \(fullSentence)")
        return fullSentence
    }
    
    subscript(index: Int) -> Word {
        return sentenceWords[index]
    }
}


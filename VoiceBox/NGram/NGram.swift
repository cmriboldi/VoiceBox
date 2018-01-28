//
//  NGram.swift
//  
//
//  Created by Andrew Hale on 1/26/18.
//

import Foundation

public class NGram {
    private var n: Int
    private var wordTrie: Trie
    
    public required init() {
        self.n = 0
        self.wordTrie = Trie()
    }
    
    public func train(textFilePath: String, n: Int) {
        self.n = n
        self.wordTrie = Trie(textFilePath: textFilePath)!
    }
    
    public func nextWords(word: String, numWords: Int) -> [String] {
        var nextWords = self.wordTrie.nextWords(word: word).sorted {(arg0, arg1) -> Bool in
            let (_, value0) = arg0
            let (_, value1) = arg1
            return value0 > value1
        }
        var probableWords = [String]()
        for index in 0..<min(numWords, nextWords.count) {
            let key = nextWords[index].key
            probableWords.append(key)
        }
        return probableWords
    }
}

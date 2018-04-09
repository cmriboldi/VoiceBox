//
//  NGram.swift
//  
//
//  Created by Andrew Hale on 1/26/18.
//

import Foundation

public class NGram {
    private var n: Int
    
    public required init() {
        self.n = 0
    }
    
//    let word1 = VocabDatabase.shared.wordForId(1)
//    let word2 = VocabDatabase.shared.wordForId(2)
//    print("word1: \(word1) \nword2: \(word2)")
//
//    let aWords = VocabDatabase.shared.wordsWithPreffix("a")
//    let bWords = VocabDatabase.shared.wordsWithPreffix("b")
//
//    print("aWords: \(aWords) \nbWords:\(bWords)")
    
    func nextWords(prevWord: Word, word: Word, numWords: Int = -1) -> [Word] {
        let textWord = word.value
        
        var nextWords = Words()
        
        if prevWord.value != "" && prevWord.nextWords![textWord] != nil {
            for (key, value) in (prevWord.nextWords?[textWord]?.nextWords)! {
                if nextWords[key] == nil {
                    nextWords[key] = Word(value: key)
                }
                // Words at depth 3 should be weighted more heavily than words at shallower depths.
                nextWords[key]?.numOccur = value.numOccur * 10
            }
        }

        for (key, value) in (word.nextWords)! {
            if nextWords[key] == nil {
                nextWords[key] = Word(value: key)
                nextWords[key]?.numOccur = 0
            }
            nextWords[key]?.numOccur += value.numOccur
        }

        let tempNextWords = nextWords.sorted {(word0, word1) -> Bool in
            let (_, actualWord0) = word0
            let (_, actualWord1) = word1
            return actualWord0.numOccur > actualWord1.numOccur
        }

        var probableWords = [Word]()
        var maxIndex = 0
        if numWords == -1 {maxIndex = tempNextWords.count}
        else {maxIndex = min(numWords, tempNextWords.count)}

//        while probableWords.count <= maxIndex {
        for i in 0..<maxIndex {
            if let word = VocabDatabase.shared.getWord(withText: tempNextWords[i].value.value) {
                if word.numOccur > 2 {probableWords.append(word)}
            }
        }

        return probableWords
    }
}


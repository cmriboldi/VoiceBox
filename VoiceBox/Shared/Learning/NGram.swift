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
    
    //FIXME: Make sure you're correctly taking both words into account
    func nextWords(prevWord: Word, word: Word, numWords: Int) -> [Word] {
        let textWord = word.value
        
        var nextWords = Words()
        
        if !(prevWord.value == "" && prevWord.imageName == "") && prevWord.nextWords![textWord] != nil {
            for (key, value) in (prevWord.nextWords![textWord]?.nextWords)! {
                if nextWords[key] == nil {
                    var imageName = ""
                    if value.imageName != nil {
                        imageName = value.imageName!
                    }
                    nextWords[key] = Word(value: key, imageName: imageName)
                }
                // Words at depth 3 should be weighted more heavily than words at shallower depths.
                nextWords[key]?.numOccur = value.numOccur * 2
            }
        }
        
        for (key, value) in (word.nextWords)! {
            if nextWords[key] == nil {
                var imageName = ""
                if value.imageName != nil {
                    imageName = value.imageName!
                }
                nextWords[key] = Word(value: key, imageName: imageName)
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
        let maxIndex = min(numWords, tempNextWords.count)
        for i in 0..<maxIndex {
            probableWords.append(VocabDatabase.shared.getWord(withText: tempNextWords[i].value.value))
        }
    
        return probableWords
    }
}

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
    
    func nextWords(prevWord: Word, word: Word, numWords: Int) -> [String] {
        let textWord = word.value
//        prevWord = Word(value: textPrevWord, imageName: imageName)
//
//        prevWord.nextWords!["am"] = Word(value: "am", imageName: "")
//        prevWord.nextWords!["am"]?.nextWords!["going"] = Word(value: "going", imageName: "")
//        prevWord.nextWords!["am"]?.nextWords!["hungry"] = Word(value: "hungry", imageName: "")
//        prevWord.nextWords!["am"]?.nextWords!["always"] = Word(value: "always", imageName: "")
//
//        prevWord.nextWords!["will"] = Word(value: "will", imageName: "")
//        prevWord.nextWords!["will"]?.nextWords!["go"] = Word(value: "go", imageName: "")
//        prevWord.nextWords!["will"]?.nextWords!["be"] = Word(value: "be", imageName: "")
//
//        prevWord.nextWords!["understand"] = Word(value: "understand", imageName: "")
//        prevWord.nextWords!["understand"]?.nextWords!["that"] = Word(value: "that", imageName: "")
//        prevWord.nextWords!["understand"]?.nextWords!["somewhat"] = Word(value: "somewhat", imageName: "")
//
//        word = Word(value: textWord, imageName: imageName)
//
//        word.nextWords!["going"] = Word(value: "going", imageName: "")
//        word.nextWords!["going"]?.nextWords!["to"] = Word(value: "to", imageName: "")
//        word.nextWords!["going"]?.nextWords!["there"] = Word(value: "there", imageName: "")
//
//        word.nextWords!["hungry"] = Word(value: "hungry", imageName: "")
//        word.nextWords!["hungry"]?.nextWords!["now"] = Word(value: "now", imageName: "")
//        word.nextWords!["hungry"]?.nextWords!["always"] = Word(value: "always", imageName: "")
//
//        word.nextWords!["capable"] = Word(value: "capable", imageName: "")
//        word.nextWords!["capable"]?.nextWords!["enough"] = Word(value: "enough", imageName: "")
//        word.nextWords!["capable"]?.nextWords!["of"] = Word(value: "of", imageName: "")
        
        var nextWords = [String:Word]()
        
        if !(prevWord.value == "" && prevWord.imageName == "") && prevWord.nextWords![textWord] != nil {
            for (key, value) in (prevWord.nextWords![textWord]?.nextWords)! {
                if let imageName = value.imageName, nextWords[key] == nil {
                    nextWords[key] = Word(value: key, imageName: imageName)
                }
                // Words at depth 3 should be weighted more heavily than words at shallower depths.
                nextWords[key]?.numOccur = value.numOccur * 2
            }
        }
        
        for (key, value) in (word.nextWords)! {
            if let imageName = value.imageName, nextWords[key] == nil {
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
        var probableWords: [String] = []
        for (key, _) in tempNextWords {
            probableWords.append(key)
        }
    
//        return Array(probableWords.values.prefix(numWords))
        return probableWords
    }
}

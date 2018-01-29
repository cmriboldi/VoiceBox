//
//  Trainer.swift
//  VoiceBox
//
//  Created by Andrew Hale on 1/29/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation

public class Trainer {
    private var textWords: [String] = []
    private var words: [String: Word] = [:]
    
    private func insertWord(textWord: String, textNextWord: String, textNextNextWord: String) {
        if self.words[textWord] == nil {
            words[textWord] = Word(value: textWord, imageName: "")
        }
        else {
            words[textWord]?.incrementNumOccur()
        }
        if textNextWord != "" {
            words[textWord]?.addWord(value: textNextWord, imageName: "")
            if textNextNextWord != "" {
                words[textWord]?.nextWords?[textNextWord]?.addWord(value: textNextNextWord, imageName: "")
            }
        }
    }
    
    public func train(textFilePath: String) {
        var textFile: String = ""
        do {textFile = try NSString.init(contentsOfFile: textFilePath, encoding: String.Encoding.utf8.rawValue) as String}
        catch {/* error handling here */}
        
        textFile.enumerateSubstrings(in: textFile.startIndex..<textFile.endIndex,
                                     options: .byWords) {
                                        (substring, _, _, _) -> () in
                                        self.textWords.append(substring!.lowercased())
                                    }
        
        var textWord = ""
        var textNextWord = ""
        
        if self.textWords.count > 0 {
            textWord = self.textWords[0]
            if self.textWords.count > 1 {
                textNextWord = self.textWords[1]
            }
        }
        
        for index in 0..<self.textWords.count {
            var textNextNextWord = ""
            if index < self.textWords.count - 2 {
                textNextNextWord = self.textWords[index+2]
            }
            self.insertWord(textWord: textWord, textNextWord: textNextWord, textNextNextWord: textNextNextWord)
            textWord = textNextWord
            textNextWord = textNextNextWord
        }
    }
}

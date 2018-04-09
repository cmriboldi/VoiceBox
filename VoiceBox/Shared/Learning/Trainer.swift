//
//  Trainer.swift
//  VoiceBox
//
//  Created by Andrew Hale on 1/29/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation

public class Trainer {
    
    // MARK: - Constants
    struct Constant {
        static let fileName = "words"
        static let fileExtension = "json"
    }
    
    // MARK: - Properties
    var fileURL: URL!
//    private var textWords: [String] = []
    private var words: Words = [:]
    
    // MARK: - Singleton
    static let shared = Trainer()
    
    // MARK: - Initialization
    fileprivate init() {
        let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        fileURL = documentDirURL.appendingPathComponent(Constant.fileName).appendingPathExtension(Constant.fileExtension)
        
        print("File Path: \(fileURL.path)")
    }
    
    // MARK: - Helper Functions
    private func insertWord(textWord: String, textNextWord: String, textNextNextWord: String) {
        if self.words[textWord] == nil {
            words[textWord] = Word(value: textWord)
        }
        else {
            words[textWord]?.incrementNumOccur()
        }
        if textNextWord != "" {
            words[textWord]?.addWord(value: textNextWord)
            if textNextNextWord != "" {
                words[textWord]?.nextWords?[textNextWord]?.addWord(value: textNextNextWord)
            }
        }
    }
    
    public func train(name fileName: String, extension fileExtension: String) {
        var textFile: String = ""
        
        if let filepath = Bundle.main.path(forResource: fileName, ofType: fileExtension) {
            do {textFile = try String(contentsOfFile: filepath)}
            catch {print("Contents of \(fileName).\(fileExtension) could not be loaded.")}
        }
        else {print("\(fileName).\(fileExtension) was not found.")}

        var textSentences: [String] = []
        textFile.enumerateSubstrings(in: textFile.startIndex..<textFile.endIndex,
                                     options: .bySentences) {
                                        (substring, _, _, _) -> () in
                                        textSentences.append(substring!.lowercased())
                                    }

        for sentence in textSentences {
            var sentenceWords: [String] = []
            sentence.enumerateSubstrings(in: sentence.startIndex..<sentence.endIndex,
                                         options: .byWords)  {
                                            (substring, _, _, _) -> () in
                                            sentenceWords.append(substring!.lowercased())
                                        }
            
            var textWord = ""
            var textNextWord = ""

            if sentenceWords.count > 0 {
                textWord = sentenceWords[0]
                if sentenceWords.count > 1 {textNextWord = sentenceWords[1]}
            }

            for index in 0..<sentenceWords.count {
//                if textWord == "fifteen" {
//                    print("fifteen")
//                }
                var textNextNextWord = ""
                if index < sentenceWords.count - 2 {textNextNextWord = sentenceWords[index+2]}
                self.insertWord(textWord: textWord, textNextWord: textNextWord, textNextNextWord: textNextNextWord)
                textWord = textNextWord
                textNextWord = textNextNextWord
            }
        }

        print("Done Training")

        writeJsonFile(words: words)
        DatabaseUpdater.shared.update(withWords: words)

        print("Done Updating Database")
    }

    func writeJsonFile(words: Words) {
        
        do {
            let writeJson = try JSONEncoder().encode(words)
            try writeJson.write(to: fileURL)
        } catch let error as NSError {
            print("Failed to write to URL.")
            print(error)
        }
        print("Done Writing to File")
    }
}

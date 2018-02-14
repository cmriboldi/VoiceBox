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
    private var textWords: [String] = []
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
    
    public func train(name fileName: String, extension fileExtension: String) {
        var textFile: String = ""
        
        if let filepath = Bundle.main.path(forResource: fileName, ofType: fileExtension) {
            do {
                textFile = try String(contentsOfFile: filepath)
            } catch {
                print("Contents of \(fileName).\(fileExtension) could not be loaded.")
            }
        } else {
            print("\(fileName).\(fileExtension) was not found.")
        }
        
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
        
        print("Done Training")
        
        writeJsonFile(words: words)
        DatabaseUpdater.shared.update(withWords: words)
        
        print("Done Updating Database")
    }
    
    func writeJsonFile(words: Words) {
        
        let writeString: String = Serializer.shared.serialize(words:words)
        
        do {
            try writeString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch let error as NSError {
            print("Failed to write to URL.")
            print(error)
        }
        print("Done Writing to File")
        
    }
    
}

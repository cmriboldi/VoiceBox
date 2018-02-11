//
//  Word.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/26/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation
import GRDB

typealias Words = [String:Word]

struct Word: TableMapping {
    
    // MARK: - Table mapping
    static let databaseTableName = "words"
    
    // MARK: - Field names
    static let id = "ID"
    static let value = "value"
    static let imageName = "imageName"
    static let json = "json"
    
    // MARK: - Properties
    public var value: String
    public var numOccur: Int
    public var imageName: String?
    public var nextWords: Words?
    
    // MARK: - Initialization
    init() {
        value = ""
        imageName = ""
        numOccur = 0
        commonInit()
    }
    
    init(json: [String:Any]) {
        guard let key = json.keys.first,
              let dict = json[key] as? [String:Any],
              let value = dict["value"] as? String,
              let numOccur = dict["numOccur"] as? Int,
              let nextWords = dict["nextWords"] as? [String:Any] else {
                self.value = ""
                self.numOccur = 0
                commonInit()
                return
        }
        
        self.value = value
        self.numOccur = numOccur
        self.nextWords = decerializeNextWords(nextWords)
    }
    
    init(value: String, imageName: String?) {
        self.value = value
        self.imageName = imageName
        numOccur = 1
        commonInit()
    }
    
    mutating func commonInit() {
        self.nextWords = Words()
    }
    
    // MARK: - Deserialization
    
    func decerializeNextWords(_ words: [String:Any]) -> [String:Word]? {
        var nextWords = Words()
        for word in words {
            nextWords[word.key] = Word(json: [word.key:word.value])
        }
        return nextWords.isEmpty ? nil : nextWords
    }
    
    // MARK: - Mutating functions
    
    mutating func incrementNumOccur() {
        self.numOccur += 1
    }
    
    mutating func addWord(value: String, imageName: String) {
        if self.nextWords?[value] == nil {
            self.nextWords?[value] = Word(value: value, imageName: imageName)
        }
        else {
            self.nextWords?[value]?.incrementNumOccur()
        }
    }
    
    

    
}

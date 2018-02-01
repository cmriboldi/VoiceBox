//
//  Word.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/26/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation
import GRDB

public struct Word {//: TableMapping, RowConvertible {
    // MARK: - Properties
    public var value: String
    public var numOccur: Int
    public var imageName: String
    public var nextWords: [String:Word]?
    
    public init(value: String, imageName: String) {
        self.value = value
        self.numOccur = 1
        self.imageName = imageName
        nextWords = [:]
    }
    
    public mutating func incrementNumOccur() {
        self.numOccur = self.numOccur + 1
    }
    
    public mutating func addWord(value: String, imageName: String) {
        if self.nextWords?[value] == nil {
            self.nextWords?[value] = Word(value: value, imageName: imageName)
        }
        else {
            self.nextWords?[value]?.incrementNumOccur()
        }
    }
    
//    // MARK: - Table mapping
//
//    static let databaseTableName = "words"
//
//    // MARK: - Field names
//
//    static let id = "ID"
//    static let word = "word"
//    static let imageName = "imageName"
//
//    // MARK: - Initialization
//
//    init() {
//        imageName = ""
//    }
//
//    init(row: Row) {
//        imageName = row[Word.imageName]
//    }
}

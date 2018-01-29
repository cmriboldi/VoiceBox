//
//  Word.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/26/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation
import GRDB

struct Word : TableMapping, RowConvertible {
    
    // MARK: - Properties
    var vaue: String
    var numOccur: Int
    var imageName: String
    var nextWords: [Word]?
    
    // MARK: - Table mapping
    
    static let databaseTableName = "words"
    
    // MARK: - Field names
    
    static let id = "ID"
    static let word = "word"
    static let imageName = "imageName"
    
    // MARK: - Initialization

    init() {
        imageName = ""
    }

    init(row: Row) {
        imageName = row[Word.imageName]
    }
}

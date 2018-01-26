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
    
    var id: Int
    var word: String
    var imageName: String?
    
    // MARK: - Table mapping
    
    static let databaseTableName = "words"
    
    // MARK: - Field names
    
    static let id = "ID"
    static let word = "word"
    static let imageName = "imageName"
    
    // MARK: - Initialization

    init() {
        id = 0
        word = ""
        imageName = ""
    }

    init(row: Row) {
        id = row[Word.id]
        word = row[Word.word]
        imageName = row[Word.imageName]
    }
}

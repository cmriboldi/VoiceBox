//
//  DatabaseUpdater.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 2/6/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation

class DatabaseUpdater {
    
    // MARK: - Constants
    
//    struct Constant {
//        static let fileName = "words"
//        static let fileExtension = "json"
//    }
    
    // MARK: - Properties
    
    var fileURL: URL!
    
    // MARK: - Singleton
    
    static let shared = DatabaseUpdater()
    
    fileprivate init() {
        
    }
    
    func update(withWords words:Words) {
        for (key,word) in words {
            if VocabDatabase.shared.doesWordExist(withText: key) {
                VocabDatabase.shared.update(word: word)
            } else {
                VocabDatabase.shared.create(word: word)
            }
        }
    }
    
    
}


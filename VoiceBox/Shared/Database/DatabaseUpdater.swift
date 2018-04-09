//
//  DatabaseUpdater.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 2/6/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation

class DatabaseUpdater {
    
    // MARK: - Properties
    
    var fileURL: URL!
    
    // MARK: - Singleton
    
    static let shared = DatabaseUpdater()
    
    fileprivate init() {
        
    }
    
    func update(withWords words:Words) {
        var successfulUpdates = 0
        var totalUpdates = 0
        var successfulCreates = 0
        var totalCreates = 0
        for (key,word) in words {
            if VocabDatabase.shared.doesWordExist(withText: key) {
                let updateSuccess = VocabDatabase.shared.update(word: word)
                successfulUpdates += (updateSuccess) ? 1 : 0
                totalUpdates += 1
            } else {
                let creationSuccess = VocabDatabase.shared.create(word: word)
                successfulCreates += (creationSuccess != nil) ? 1 : 0
                totalCreates += 1
            }
        }
        print("Successfully updated \(successfulUpdates)/\(totalUpdates)")
        print("Successfully created \(successfulCreates)/\(totalCreates)")
    }
}

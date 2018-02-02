//
//  VocabDatabase.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/26/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation
import GRDB

class VocabDatabase {
    
    // MARK: - Constants
    
    struct Constant {
        static let fileName = "VocabularyDB"
        static let fileExtension = "db"
    }
    
    // MARK: - Properties
    
    var dbQueue: DatabaseQueue!
    
    // MARK: - Singleton
    
    static let shared = VocabDatabase()
    
    fileprivate init() {
        dbQueue = try? DatabaseQueue(path: Bundle.main.path(forResource: Constant.fileName, ofType: Constant.fileExtension)!)
    }
    

    // MARK: - Helpers

    //
    // Return a Word object for the given word ID.
    //
    func wordForId(_ wordId: Int) -> Word {
        do {
            let word = try dbQueue.inDatabase{ (db: Database) -> Word in
                let row = try Row.fetchOne(db,
                                           "select * from \(Word.databaseTableName) " +
                                           "where \(Word.id) = ?",
                                           arguments: [wordId])
                if let row = row, let data = row[Word.json] as? String {
                    if let jsonData = data.data(using: .utf8, allowLossyConversion: false) {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String:Any] {
                                return Word(json: json)
                            }
                        } catch {
                            print("Error deserializing the json")
                            print(error)
                            return Word()
                        }
                    }
                }
                return Word()
            }
            return word
        } catch {
            return Word()
        }
    }

//    //
//    // Return an array of Word objects for the given preffix.
//    //
//    func wordsWithPreffix(_ preffix: String) -> [Word] {
//        do {
//            let words = try dbQueue.inDatabase{ (db: Database) -> [Word] in
//                var words = [Word]()
//                let rows = try Row.fetchCursor(db,
//                                                "select * from \(Word.databaseTableName) " +
//                                                "where \(Word.word) like ?",
//                                                arguments: ["\(preffix)%"])
//                while let row = try rows.next() {
//                    words.append(Word(row: row))
//                }
//                return words
//            }
//            return words
//        } catch {
//            return []
//        }
//    }
}

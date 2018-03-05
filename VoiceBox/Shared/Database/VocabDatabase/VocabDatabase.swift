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
    
    struct Temp {
        static let primerWords = ["am","are","will","i","do"]
    }
    
    // MARK: - Properties
    
    var dbQueue: DatabaseQueue!
    var fileName: String {
        return "\(Constant.fileName).\(Constant.fileExtension)"
    }
    var dbFilePath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return (documentsDirectory as NSString).appendingPathComponent(fileName)
    }
    
    // MARK: - Singleton
    
    static let shared = VocabDatabase()
    
    fileprivate init() {
        copyDBToDevice()
        initDatabase()
        print("dbFilePath is: \(dbFilePath)")
    }
    
    func copyDBToDevice() {
        // Check if the database already exists and if not, copy it over
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbFilePath), let pathToDefaultDB = Bundle.main.path(forResource: Constant.fileName, ofType: Constant.fileExtension) {
            do {
                try fileManager.copyItem(atPath: pathToDefaultDB, toPath: dbFilePath)
            } catch let error {
                assertionFailure("Failed to copy data with error message \(error.localizedDescription)")
            }
        }
    }
    
    func initDatabase() {
        dbQueue = try? DatabaseQueue(path: dbFilePath)
    }
    
    // MARK: - Getters
    //
    // Return a Word object for the given word ID.
    //
    func getWord(withText wordText: String) -> Word? {
        do {
            let word = try dbQueue.inDatabase{ (db: Database) -> Word? in
                
                let row = try Row.fetchOne(db,
                                           "select * from \(Word.databaseTableName) " +
                    "where \(Word.Database.value) = ?",
                    arguments: [wordText])
                if let row = row, let data = row[Word.Database.json] as? Data {
                    let word = try JSONDecoder().decode(Word.self, from: data)
                    return word
                }
                return nil
            }
            return word
        } catch {
            return nil
        }
    }
    
    //
    // Return a Word object for the given word ID.
    //
    func getWord(withId wordId: Int) -> Word? {
        do {
            let word = try dbQueue.inDatabase{ (db: Database) -> Word? in
                let row = try Row.fetchOne(db,
                                           "select * from \(Word.databaseTableName) " +
                    "where \(Word.Database.id) = ?",
                    arguments: [wordId])
                if let row = row, let data = row[Word.Database.json] as? Data {
                    let word = try JSONDecoder().decode(Word.self, from: data)
                    return word
                }
                return nil
            }
            return word
        } catch {
            return nil
        }
    }
    
    //
    // Return an array of Word objects for the given preffix.
    //
    func getWords(withPreffix preffix: String) -> [Word] {
        do {
            let words = try dbQueue.inDatabase{ (db: Database) -> [Word] in
                var words = [Word]()
                let rows = try Row.fetchAll(db,
                                            "select * from \(Word.databaseTableName) " +
                    "where \(Word.Database.value) like \"\(preffix)\"")
                for row in rows {
                    if let data = row[Word.Database.json] as? Data {
                        let word = try JSONDecoder().decode(Word.self, from: data)
                        words.append(word)
                    }
                }
                return words
            }
            return words
        } catch {
            return []
        }
    }
    
    //
    // Returns the words that the sentence creator should start with.
    //
    func getStartingWords(n _: Int) -> [Word] {
        var startingWords = [Word]()
        for wordText in Temp.primerWords {
            if let word = self.getWord(withText: wordText) {
                startingWords.append(word)
            }
        }
        return startingWords
    }
    
    
    // MARK: - Setters
    //
    // Creates a row in the database with the values contained in word.
    //
    func create(word: Word) -> Int? {
        do {
            let newWordID = try dbQueue.inDatabase{ (db: Database) -> Int in
                let json = try JSONEncoder().encode(word)
                try db.execute("""
                    insert into \(Word.databaseTableName) (\(Word.Database.value), \(Word.Database.json))
                    values (?,?,?)
                    """, arguments: [word.value, json])
                let wordID = db.lastInsertedRowID
                return Int(truncatingIfNeeded: wordID)
            }
            return newWordID
        } catch {
            return nil
        }
    }
    
    //
    // Updates the word in the databade with the values contained in word.
    //
    func update(word: Word) -> Bool {
        do {
            let success = try dbQueue.inDatabase{ (db: Database) -> Bool in
                let json = try JSONEncoder().encode(word)
                //                let json = Serializer.shared.serialize(word: word)
                try db.execute("""
                    update \(Word.databaseTableName)
                    set \(Word.Database.json) = ?
                    where \(Word.Database.value) = ?
                    """, arguments: [json, word.value])
                return true
            }
            return success
        } catch {
            return false
        }
    }
    
    //
    // Deletes the word in the databade with the values contained in word.
    //
    func delete(word: Word) -> Bool {
        do {
            let success = try dbQueue.inDatabase{ (db: Database) -> Bool in
                try db.execute("""
                    delete from \(Word.databaseTableName)
                    where \(Word.Database.value) = ?
                    """, arguments: [word.value])
                return true
            }
            return success
        } catch {
            return false
        }
    }
    
    func delete(wordWithText text: String) -> Bool {
        return self.delete(word: Word.init(value: text))
    }
    
    // MARK: - Queries
    //
    // Returns true if the word exists in the database.
    //
    func doesWordExist(withText wordText: String) -> Bool {
        do {
            let doesWordExist = try dbQueue.inDatabase{ (db: Database) -> Bool in
                let row = try Row.fetchOne(db,
                                           "select * from \(Word.databaseTableName) " +
                    "where \(Word.Database.value) = ?",
                    arguments: [wordText])
                if row != nil {
                    return true
                }
                return false
            }
            return doesWordExist
        } catch {
            return false
        }
    }
}

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
    func getWord(withText wordText: String) -> Word {
        do {
            let word = try dbQueue.inDatabase{ (db: Database) -> Word in
                let row = try Row.fetchOne(db,
                                           "select * from \(Word.databaseTableName) " +
                                           "where \(Word.value) = ?",
                                           arguments: [wordText])
                if let row = row, let data = row[Word.json] as? String {
                    return Deserializer.shared.deserialize(jsonWord: data)
                }
                return Word()
            }
            return word
        } catch {
            return Word()
        }
    }
    
    //
    // Return a Word object for the given word ID.
    //
    func getWord(withId wordId: Int) -> Word {
        do {
            let word = try dbQueue.inDatabase{ (db: Database) -> Word in
                let row = try Row.fetchOne(db,
                                           "select * from \(Word.databaseTableName) " +
                                           "where \(Word.id) = ?",
                                           arguments: [wordId])
                if let row = row, let data = row[Word.json] as? String {
                    return Deserializer.shared.deserialize(jsonWord: data)
                }
                return Word()
            }
            return word
        } catch {
            return Word()
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
                                            "where \(Word.value) like \"\(preffix)\"")
                for row in rows {
                    if let data = row[Word.json] as? String {
                        words.append(Deserializer.shared.deserialize(jsonWord: data))
                    }
                }
                return words
            }
            return words
        } catch {
            return []
        }
    }
    
    // MARK: - Setters
    //
    // Creates a row in the database with the values contained in word.
    //
    func create(word: Word) -> Int? {
        do {
            let newWordID = try dbQueue.inDatabase{ (db: Database) -> Int in
                let json = Serializer.shared.serialize(word: word)
                try db.execute("""
                    insert into \(Word.databaseTableName) (\(Word.value), \(Word.imageName), \(Word.json))
                    values (?,?,?)
                    """, arguments: [word.value, word.imageName, json])
                let wordID = db.lastInsertedRowID
                return Int(truncatingIfNeeded: wordID)
            }
            return newWordID
        } catch {
            return nil
        }
        // TODO: I need to fix the Serializer so that it serializes the word correctly.
    }
    
    //
    // Updates the word in the databade with the values contained in word.
    //
    func update(word: Word) -> Bool {
        // TODO: I need to call the Serializer with the word in order to get the right JSON and then I need to update the row with those values.
        do {
            let success = try dbQueue.inDatabase{ (db: Database) -> Bool in
                let json = Serializer.shared.serialize(word: word)
                try db.execute("""
                    update \(Word.databaseTableName)
                    set \(Word.imageName) = ?, \(Word.json) = ?
                    where \(Word.value) = ?
                    """, arguments: [word.imageName, json, word.value])
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
                    where \(Word.value) = ?
                    """, arguments: [word.value])
                return true
            }
            return success
        } catch {
            return false
        }
    }
    
    func delete(wordWithText text: String) -> Bool {
        return self.delete(word: Word.init(value: text, imageName: nil))
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
                                           "where \(Word.value) = ?",
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

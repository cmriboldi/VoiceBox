//
//  Word.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/26/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit
import GRDB

enum WordType: String, Encodable, Decodable{
    case word, folder
    var description: String {
        return self.rawValue.uppercased()
    }
}

enum WordColor: String, Encodable, Decodable {
    case orange, pink, blue, green, yellow, indigo, white, gray
}

typealias Words = [String:Word]

struct Word: TableMapping, Encodable, Decodable {
    // MARK: - Table mapping
    static let databaseTableName = "words"

    // MARK: - Field names
    struct Database {
        static let id = "ID"
        static let value = "value"
        static let imageName = "imageName"
        static let json = "json"
    }

    // MARK: - Properties
    var value: String
    var numOccur: Int
    var nextWords: Words?
    var type = WordType.word
    var buttonColor: WordColor? = .orange
    var imageName: String? {
        return "\(value)_img"
    }
    var image: UIImage? {
        let imgName = self.imageName ?? ""
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if paths.count > 0 {
            if let dirPath = paths.first {
                if let readPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(value + "_img.png") {
                    do {
                        let imageData = try Data(contentsOf: readPath)
                        return UIImage(data: imageData)
                    }
                    catch {print("Error loading image : \(error)")}
                }
            }
        }
        return UIImage.init(named: "")
//        return UIImage.init(named: imgName)
    }
    var spokenPhrase: String? {
        get {
            return value
        }
    }
    
    // MARK: - Initialization
    init() {
        self.value = ""
        numOccur = 0
        commonInit()
    }
    
    init(value: String) {
        self.value = value
        numOccur = 1
        commonInit()
    }
    
    init (_ word: Word) {
        self.value = word.value
        self.numOccur = word.numOccur
        self.nextWords = word.nextWords
    }

    mutating func commonInit() {
        self.nextWords = Words()
    }
    
    // MARK: - Mutating functions

    mutating func incrementNumOccur() {
        self.numOccur += 1
    }

    mutating func addWord(value: String) {
        if self.nextWords?[value] == nil {
            self.nextWords?[value] = Word(value: value)
        }
        else {
            self.nextWords?[value]?.incrementNumOccur()
        }
    }
    
}

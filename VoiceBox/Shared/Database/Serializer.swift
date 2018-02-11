//
//  Serializer.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 2/7/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation

class Serializer {
    
    // MARK: - Singleton
    static let shared = Serializer()
    
    fileprivate init() {
        
    }
    
    // MARK: - Methods
    
    //
    // Serializes a single word into a JSON string.
    //
    func serialize(word: Word?, iteration: Int) -> String {
        var json = "{}"
        if let word = word {
            json = "{\(word.value)}"
        }
        return json
    }

    //
    // Serializes multiple words into a human readable JSON string.
    //
    // TODO: Refactor the [] code to this function and move the majority of this code to use the serialize(word) funciton.
    //       Another thing I might want to make is to make a boolean value that can state whether you want it to be human readable or just a regular string.
    //       I'm probably also going to look into the good that other Pods might be able to provide for me here in this function.
    func serialize(words: Words?, iteration: Int) -> String {
        let baseTabs = String(repeating: "\t", count: iteration-1)
        let repeatTabs = baseTabs + "\t"
        var json = "{\n"
        if let words = words {
            var count = 0
            for (key, word) in words {
                json += """
                \(repeatTabs)"\(key)": {
                \(repeatTabs)\t"value": "\(word.value)",
                \(repeatTabs)\t"numOccur": \(word.numOccur),
                \(repeatTabs)\t"nextWords": \(serialize(words: word.nextWords, iteration: iteration+2))
                \(repeatTabs)}
                """
                count += 1
                if count != words.count {
                    json += ",\n"
                }
            }
        }
        json += "\n\(baseTabs)}"
        return (json == "{\n\n\(baseTabs)}") ? "{}" : json
    }
}

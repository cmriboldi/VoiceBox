//
//  Deserializer.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 2/7/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation

class Deserializer {
    
    // MARK: - Singleton
    static let shared = Deserializer()
    
    fileprivate init() {
        
    }
    
    // MARK: - Methods
    func deserialize(jsonWord dataString: String) -> Word {
        if let jsonData = dataString.data(using: .utf8, allowLossyConversion: false) {
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
        return Word()
    }
}

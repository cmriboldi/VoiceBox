//
//  String+helpers.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 2/14/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation

extension String {
    
    func minimized() -> String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }
    
}

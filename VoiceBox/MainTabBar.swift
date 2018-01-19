//
//  MainTabBar.swift
//  VoiceBox
//
//  Created by Andrew Hale on 1/18/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import Foundation
import UIKit

class MainTabBar : UITabBarController {
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.selectedIndex = 2//required value
    }
    
//    var freshLaunch = true
//    override func viewDidLoad() {
//        if freshLaunch == true {
//            freshLaunch = false
//            self.tabBarController?.selectedIndex = 1
//        }
//    }
}

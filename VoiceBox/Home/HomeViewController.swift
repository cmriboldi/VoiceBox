//
//  HomeViewController.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/16/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var mainWord: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)

        mainWord?.layer.cornerRadius = 0.5 * mainWord.bounds.size.width
        mainWord?.layer.borderColor = UIColor.black.cgColor
        mainWord?.layer.borderWidth = 2.0
//        mainWord?.center = self.view.center

        
//        mainWord?.layer.shadowColor = UIColor.black.cgColor
//        mainWord?.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
//        mainWord?.layer.masksToBounds = false
//        mainWord?.layer.shadowRadius = 2.0
//        mainWord?.layer.shadowOpacity = 0.5
//        mainWord?.layer.cornerRadius = mainWord.frame.width / 2
//        mainWord?.layer.borderColor = UIColor.black.cgColor
//        mainWord?.layer.borderWidth = 2.0
    }
    
    @objc func swiped(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if (self.tabBarController?.selectedIndex)! < 3 { // set your total tabs here
                self.tabBarController?.selectedIndex += 1
            }
        }
        else if gesture.direction == .right {
            if (self.tabBarController?.selectedIndex)! > 0 {
                self.tabBarController?.selectedIndex -= 1
            }
        }
    }
}

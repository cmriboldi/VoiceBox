//
//  HomeViewController.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/16/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var inputWord: UITextField!
    @IBOutlet weak var mainWord: UIButton!
    @IBAction func train(_ sender: UIButton) {
        let trainer = Trainer()
        trainer.train(textFilePath: "/Users/andrewhale/Documents/CS498R/VoiceBox/VoiceBox/Shared/Data/train.txt")
    }
    @IBOutlet weak var wordList: WordList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputWord.delegate = self
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)

        mainWord?.layer.cornerRadius = 0.5 * mainWord.bounds.size.width
        mainWord?.layer.borderColor = UIColor.black.cgColor
        mainWord?.layer.borderWidth = 2.0
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func doMachineLearning(word: String, numWords: Int) -> [String] {
        var probableWords = [String]()
        
        let ngram = NGram()
        ngram.train(textFilePath: "/Users/andrewhale/Documents/CS498R/VoiceBox/VoiceBox/Shared/Data/train.txt", n: 3)
        probableWords = ngram.nextWords(word: word, numWords: numWords)
        
        return probableWords
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let probableWords = doMachineLearning(word: textField.text!.lowercased(), numWords: 5)
        
        wordList.words = probableWords
        wordList.setupWords()
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

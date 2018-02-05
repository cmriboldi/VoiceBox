//
//  HomeViewController.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/16/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate {
    var textPrevWord: String = ""
    var prevWord: Word = Word(value: "", imageName: "")
    
    @IBOutlet weak var inputWord: UITextField!
    @IBOutlet weak var mainWord: UIButton!
    @IBAction func train(_ sender: UIButton) {
        let trainer = Trainer()
        trainer.train(name: "train", extension: "txt")
    }
    @IBOutlet weak var wordList: WordList!
    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//
//        if viewController == self {return false}
//
//        let fromView = self.view
//        let toView = viewController.view
//
//        UIView.transition(from: fromView!, to: toView!, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
//
//        return true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputWord.delegate = self
        
//        self.tabBarController.setSwipeAnimation(type: SwipeAnimationType.sideBySide)
        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
//        swipeRight.direction = UISwipeGestureRecognizerDirection.right
//        self.view.addGestureRecognizer(swipeRight)
//
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
//        self.view.addGestureRecognizer(swipeLeft)

        mainWord?.layer.cornerRadius = 0.5 * mainWord.bounds.size.width
        mainWord?.layer.borderColor = UIColor.black.cgColor
        mainWord?.layer.borderWidth = 2.0
        
        let word1 = VocabDatabase.shared.wordForId(1)
        print("Done getting word:\(word1)")
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func doMachineLearning(textWord: String, numWords: Int) -> [String] {
        var probableWords = [String]()
        
        let ngram = NGram()
//        ngram.train(textFilePath: "/Users/andrewhale/Documents/CS498R/VoiceBox/VoiceBox/Shared/Data/train.txt", n: 3)
//        probableWords = ngram.nextWords(textPrevWord: word, textWord: word, numWords: numWords)
        let word = VocabDatabase.shared.getWord(word: textWord)
        probableWords = ngram.nextWords(prevWord: self.prevWord, word: word, numWords: numWords)
        self.textPrevWord = textWord
        self.prevWord = word
        
        return probableWords
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let input = textField.text!.lowercased().components(separatedBy: " ").last
        let probableWords = doMachineLearning(textWord: input!, numWords: 5)
        
        wordList.words = probableWords
        wordList.setupWords()
    }
    
//    @objc func swiped(_ gesture: UISwipeGestureRecognizer) {
//        if gesture.direction == .left {
//            if (self.tabBarController?.selectedIndex)! < 3 { // set your total tabs here
////                let fromView = self.tabBarController?.selectedViewController!.view
//                self.tabBarController?.selectedIndex += 1
//
////                let toView = self.tabBarController?.selectedViewController!.view
////
////                UIView.transition(from: fromView!, to: toView!, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
//            }
//        }
//        else if gesture.direction == .right {
//            if (self.tabBarController?.selectedIndex)! > 0 {
//                self.tabBarController?.selectedIndex -= 1
//            }
//        }
//    }
}

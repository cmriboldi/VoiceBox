//
//  HomeViewController.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/16/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    var textPrevWord: String = ""
    var prevWord: Word = Word(value: "", imageName: "")
    let customNavigationAnimationController = CustomNavigationAnimationController()
    
    @IBOutlet weak var inputWord: UITextField!
    var currentWord: String = ""
    @IBOutlet weak var mainWord: UIButton!
    var likelyNextWords: [String] = ["about", "after", "again", "ah", "all"]
    @IBOutlet var wordButtons: [UIButton]!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteWord(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func train(_ sender: UIButton) {
        Trainer.shared.train(name: "train", extension: "txt")
    }
    
    //TODO
    @IBAction func wordPressed(_ sender: Any) {
//        print("pressed")
        let newWord = (sender as! UIButton).currentTitle
        let newScreen = HomeViewController.makeFromStoryboard()
        let probableWords = self.doMachineLearning(textWord: newWord!, numWords: 5)
        
        newScreen.currentWord = newWord!
        
        newScreen.likelyNextWords = []
        for word in probableWords {
            newScreen.likelyNextWords.append(word)
        }
        
        self.navigationController?.pushViewController(newScreen, animated: true)
    }
    
    @IBOutlet weak var wordList: WordList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = true
        }
        
        inputWord.delegate = self
        
        self.mainWord.setTitle(self.currentWord, for: .normal)
        
        for i in 0..<min(5, self.likelyNextWords.count) {
            self.wordButtons[i].setTitle(self.likelyNextWords[i], for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
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
        let word = VocabDatabase.shared.getWord(withText: textWord)

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
    
    static func makeFromStoryboard() -> HomeViewController {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            return HomeViewController()
        }
        return viewController
    }
    
    //MARK: - UINavigationControllerAnimationDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        customNavigationAnimationController.reverse = operation == .pop
        return customNavigationAnimationController
    }
}

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
    var currentWord: String = ""
    @IBOutlet weak var mainWord: UIButton!
    var likelyNextWords: [String] = ["about", "after", "again", "ah", "all"]
    @IBOutlet var wordButtons: [UIButton]!
    
    @IBAction func train(_ sender: UIButton) {
        let trainer = Trainer()
        trainer.train(name: "train", extension: "txt")
    }
    
    //TODO
    @IBAction func wordPressed(_ sender: Any) {
//        print("pressed")
        var newWord = (sender as! UIButton).currentTitle
        var newScreen = HomeViewController.makeFromStoryboard()
        var probableWords = self.doMachineLearning(textWord: newWord!, numWords: 5)
        
        newScreen.currentWord = newWord!
        
        newScreen.likelyNextWords = []
        for word in probableWords {
            newScreen.likelyNextWords.append(word)
        }
        
        self.present(newScreen, animated: true, completion: nil)
    }
    
    @IBOutlet weak var wordList: WordList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputWord.delegate = self
        
        let word1 = VocabDatabase.shared.wordForId(1)
        print("Done getting word:\(word1)")
        
        self.mainWord.setTitle(self.currentWord, for: .normal)
        
        for i in 0..<min(5, self.likelyNextWords.count) {
            self.wordButtons[i].setTitle(self.likelyNextWords[i], for: .normal)
        }
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
    
    static func makeFromStoryboard() -> HomeViewController {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            return HomeViewController()
        }
        return viewController
    }
}

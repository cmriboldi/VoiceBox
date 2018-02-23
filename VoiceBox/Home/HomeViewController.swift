//
//  HomeViewController.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/16/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit
import IBAnimatable
import AVFoundation

class HomeViewController: UIViewController {
    
    // MARK: - Constants
    private struct Storyboard {
        static let SentenceWordCellID = "sentenceWordCell"
    }
    
    // MARK: - Properties
    var triggerButtonIndex = 0
    var synth = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string: "")
    var sentenceWordIndex = 0
    var sentence = Sentence()
    var prevWord: Word = Word(value: "", imageName: "")
    var currentWord: Word = Word(value: "", imageName: "")
    var likelyNextWords = [Word]()
    var transitionThumbnail: UIImageView?

    @IBOutlet weak var sentenceCollectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mainWord: UIButton!
    @IBOutlet var wordButtons: [UIButton]!
    
    // MARK: - ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = true
        }
        
        sentenceCollectionView.delegate = self
        sentenceCollectionView.dataSource = self
        
        if likelyNextWords.isEmpty {
            likelyNextWords = VocabDatabase.shared.getStartingWords(n: 5)
        }
        
        populateWordButtons()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        sentenceCollectionView.collectionViewLayout = flowLayout
        
        
        let recognizer = UITapGestureRecognizer(target: self,action:#selector(self.handleTap(recognizer:)))
        recognizer.delegate = self
        sentenceCollectionView.addGestureRecognizer(recognizer)
        
        deleteButton.addTarget(self, action: #selector(clearSentence(_:event:)), for: UIControlEvents.touchDownRepeat)
    }
    
    // MARK: - Actions
    @IBAction func wordPressed(_ button: RoundButton) {
        guard button.tag < likelyNextWords.count else {
            return
        }

        triggerButtonIndex = wordButtons.index(of: button)!

        var newWord = self.likelyNextWords[button.tag]

        self.likelyNextWords = predictNextWords(newWord: newWord, numWords: 5)
        print("\n\nselected word is: \(newWord.value)")

        speakPhrase(newWord.spokenPhrase.lowercased())
        
        self.sentence.append(newWord)
        self.sentenceCollectionView.setNeedsLayout()
        
        let sentenceIndexPath = IndexPath(row:self.sentenceWordIndex, section: 0)
        self.sentenceCollectionView.insertItems(at: [sentenceIndexPath])
        self.sentenceCollectionView.scrollToItem(at: sentenceIndexPath, at: .right, animated: true)
        self.sentenceWordIndex += 1
        
        let centerCornerX = Double(mainWord.center.x) - Double(mainWord.bounds.width / 2)
        let centerCornerY = Double(mainWord.center.y) - Double(mainWord.bounds.height / 2)
        
        button.animate(.moveTo(x: centerCornerX, y: centerCornerY))
        
        populateWordButtons()

    }
    
    @IBAction func deleteWord(_ sender: Any) {
        if !sentence.isEmpty {
            sentenceWordIndex -= 1
            sentence.removeLast()
            let indexPath = IndexPath(row:sentenceWordIndex, section: 0)
            self.sentenceCollectionView.deleteItems(at: [indexPath])
        }
    }
    
    // Currently unused
    @IBAction func train(_ sender: UIButton) {
        Trainer.shared.train(name: "train", extension: "txt")
    }
    
    // MARK: - Helper Functions
    @objc func clearSentence(_ sender: UIButton, event: UIEvent) {
        let touch: UITouch = event.allTouches!.first!
        if (touch.tapCount == 2) {
            sentence.removeAll()
            sentenceWordIndex = 0
            sentenceCollectionView.reloadData()
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func populateWordButtons() {
        self.mainWord.setTitle(self.getWordText(word: self.currentWord), for: .normal)
        
        for (i,likelyWord) in self.likelyNextWords.enumerated() {
            self.wordButtons[i].setTitle(self.getWordText(word: likelyWord), for: .normal)
        }
    }
    
    func getWordText(word: Word) -> String {
        if word.value == "i" {return "I"}
        return word.value
    }
    
    func speakPhrase(_ phrase: String) {
        synth = AVSpeechSynthesizer()
        utterance = AVSpeechUtterance(string: phrase)
        utterance.rate = 0.4
        synth.speak(utterance)
    }
    
    func predictNextWords(newWord: Word, numWords: Int) -> [Word] {
        self.prevWord = self.currentWord
        self.currentWord = newWord
        let ngram = NGram()

        return ngram.nextWords(prevWord: self.prevWord, word: self.currentWord, numWords: numWords)
    }
    
    static func makeFromStoryboard() -> HomeViewController {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            return HomeViewController()
        }
        return viewController
    }
    
}

extension HomeViewController: UIGestureRecognizerDelegate {
    @objc func handleTap(recognizer:UITapGestureRecognizer) {
        speakPhrase(sentence.getSpokenSentence())
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (section == 0) ? sentence.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.SentenceWordCellID, for: indexPath)
        let word = sentence[indexPath.item]
        if let sentenceWordCell = cell as? SentenceWordCell {
            sentenceWordCell.sentenceItemView.word = word
            sentenceWordCell.sentenceItemView.setNeedsDisplay()
            return sentenceWordCell
        }
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected the \(indexPath.item)th item in the sentence collection view.")
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 91, height: 91)
    }
}

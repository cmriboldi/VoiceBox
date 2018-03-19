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
    var prevWord: Word = Word(value: "")
    var currentWord: Word = Word(value: "")
    var numWords: Int = 5
    var likelyNextWords = [Word]()
    var transitionThumbnail: UIImageView?

    @IBOutlet weak var sentenceCollectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mainWord: UIButton!
    @IBOutlet var wordButtons: [RoundButton]!
    
    // MARK: - ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = true
        }
        
        sentenceCollectionView.delegate = self
        sentenceCollectionView.dataSource = self

        if likelyNextWords.isEmpty {self.likelyNextWords = VocabDatabase.shared.getStartingWords(n: numWords)}
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
        guard button.tag < likelyNextWords.count else {return}

        triggerButtonIndex = wordButtons.index(of: button)!

        let newWord = VocabDatabase.shared.getWord(withText: self.likelyNextWords[button.tag].value)!

        self.likelyNextWords = self.predictNextWords(newWord: newWord)

        speakPhrase(newWord.spokenPhrase?.lowercased() ?? newWord.value.lowercased())

        self.sentence.append(newWord)
        self.sentenceCollectionView.setNeedsLayout()

        let sentenceIndexPath = IndexPath(row:self.sentenceWordIndex, section: 0)
        self.sentenceCollectionView.insertItems(at: [sentenceIndexPath])
        self.sentenceCollectionView.scrollToItem(at: sentenceIndexPath, at: .right, animated: true)
        self.sentenceWordIndex += 1
        
        let pressedCenterCornerX = Double(button.center.x) - Double(button.bounds.width / 2)
        let pressedCenterCornerY = Double(button.center.y) - Double(button.bounds.height / 2)
        let centerCornerX = Double(mainWord.center.x) - Double(mainWord.bounds.width / 2)
        let centerCornerY = Double(mainWord.center.y) - Double(mainWord.bounds.height / 2)
        
        button.animate(.moveTo(x: centerCornerX, y: centerCornerY))
        
        for otherButton in self.wordButtons {
            if otherButton != button {
                let buttonCenterCornerX = Double(otherButton.center.x) - Double(otherButton.bounds.width / 2)
                let buttonCenterCornerY = Double(otherButton.center.y) - Double(otherButton.bounds.height / 2)
                otherButton.animate(.moveTo(x: centerCornerX, y: centerCornerY))
                otherButton.animate(.fade(way: .out)).then(.moveTo(x: buttonCenterCornerX, y: buttonCenterCornerY)).completion({
                    if otherButton == self.wordButtons.last || otherButton == self.wordButtons.secondToLast {
                        self.populateWordButtons(closure: {
                            let wordChangeDelay = 0.1
                            let showWordsDelay = 0.2
                            button.delay(wordChangeDelay).completion({button.alpha = 0})
                            button.delay(wordChangeDelay).then(.moveTo(x: pressedCenterCornerX, y: pressedCenterCornerY), duration: 0.0).delay(showWordsDelay).then(.fade(way: .in))
                            for otherButton in self.wordButtons {
                                if otherButton != button {otherButton.delay(wordChangeDelay + showWordsDelay).then(.fade(way: .in))}
                            }
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func deleteWord(_ sender: Any) {
        if !sentence.isEmpty {
            sentenceWordIndex -= 1
            sentence.removeLast()
            let indexPath = IndexPath(row:sentenceWordIndex, section: 0)
            self.sentenceCollectionView.deleteItems(at: [indexPath])
            
            if self.sentence.count >= 1 {self.currentWord = Word(self.sentence[self.sentence.count - 1])}
            else {self.currentWord = Word()}
            if self.sentence.count >= 2 {self.prevWord = Word(self.sentence[self.sentence.count - 2])}
            else {self.prevWord = Word()}
            if self.currentWord.value == "" {self.likelyNextWords = VocabDatabase.shared.getStartingWords(n: numWords)}
            else {self.likelyNextWords = NGram().nextWords(prevWord: self.prevWord, word: self.currentWord)}
            self.populateWordButtons()
        }
    }
    
    @IBAction func search(_ sender: UIButton) {
        let vocabViewController = (tabBarController?.viewControllers![0] as! UINavigationController).viewControllers[0] as! VocabViewController
        
        vocabViewController.vocabulary.clear(type: "likely")
        self.likelyNextWords = self.likelyNextWords.sorted{$0.value < $1.value}
        for word in self.likelyNextWords {vocabViewController.vocabulary.addChild(child: VocabularyWord(name: word.value), parentName: "", type: "likely")}
        
        vocabViewController.loadNodes("")
        vocabViewController.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        vocabViewController.isSearching = false
        tabBarController?.selectedIndex = 0
    }

    // MARK: - Helper Functions
    @objc func clearSentence(_ sender: UIButton, event: UIEvent) {
        let touch: UITouch = event.allTouches!.first!
        if (touch.tapCount == 2) {
            sentence.removeAll()
            sentenceWordIndex = 0
            sentenceCollectionView.reloadData()
            navigationController?.popToRootViewController(animated: true)
//
            self.prevWord = Word(value: "")
            self.currentWord = Word(value: "")
            self.likelyNextWords = VocabDatabase.shared.getStartingWords(n: numWords)
            self.populateWordButtons()
        }
    }

    func populateWordButtons(closure: (() -> Void)? = nil) {
        self.mainWord.setTitle(self.getWordText(word: self.currentWord), for: .normal)
        for i in 0..<self.numWords {
            var word: Word = Word()
            if i < self.likelyNextWords.count {word = self.likelyNextWords[i]}
            self.wordButtons[i].setTitle(self.getWordText(word: word), for: .normal)
        }
        closure?()
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

    func predictNextWords(newWord: Word, numWords: Int = -1) -> [Word] {
        self.prevWord = self.currentWord
        self.currentWord = newWord

        return NGram().nextWords(prevWord: self.prevWord, word: self.currentWord, numWords: numWords)
    }

    static func makeFromStoryboard() -> HomeViewController {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            return HomeViewController()
        }
        return viewController
    }
    
    // Currently unused
    func train() {
        Trainer.shared.train(name: "train", extension: "txt")
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

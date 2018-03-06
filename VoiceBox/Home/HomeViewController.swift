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
        
        if likelyNextWords.isEmpty {
            likelyNextWords = VocabDatabase.shared.getStartingWords(n: 5)
        }
        
        populateWordButtons()
        let wordsBegginingInA = VocabDatabase.shared.getWords(withPreffix: "a")
        let wordsBegginingInB = VocabDatabase.shared.getWords(withPreffix: "b")
        let wordsBegginingInC = VocabDatabase.shared.getWords(withPreffix: "c")
        print("wordsBegginingInA count is: \(wordsBegginingInA.count)")
        print("wordsBegginingInB count is: \(wordsBegginingInB.count)")
        print("wordsBegginingInC count is: \(wordsBegginingInC.count)")
        let wordsContainingA = VocabDatabase.shared.getWords(withSubstring: "a")
        let wordsContainingB = VocabDatabase.shared.getWords(withSubstring: "b")
        let wordsContainingC = VocabDatabase.shared.getWords(withSubstring: "c")
        print("wordsContainingA count is: \(wordsContainingA.count)")
        print("wordsContainingB count is: \(wordsContainingB.count)")
        print("wordsContainingC count is: \(wordsContainingC.count)")
        let wordsEndingInA = VocabDatabase.shared.getWords(withEnding: "a")
        let wordsEndingInB = VocabDatabase.shared.getWords(withEnding: "b")
        let wordsEndingInC = VocabDatabase.shared.getWords(withEnding: "c")
        print("aWords count is: \(wordsEndingInA.count)")
        print("bWords count is: \(wordsEndingInB.count)")
        print("cWords count is: \(wordsEndingInC.count)")
        
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

        let newWord = self.likelyNextWords[button.tag]

        self.likelyNextWords = predictNextWords(newWord: newWord, numWords: 5)

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
                            button.delay(wordChangeDelay).then(.moveTo(x: pressedCenterCornerX, y: pressedCenterCornerY), duration: 0.0)
                                .delay(showWordsDelay)
                                .then(.fade(way: .in))
                            for otherButton in self.wordButtons {
                                if otherButton != button {
                                    otherButton.delay(wordChangeDelay + showWordsDelay).then(.fade(way: .in))
                                }
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
    
    func populateWordButtons(closure: (() -> Void)? = nil) {
        self.mainWord.setTitle(self.getWordText(word: self.currentWord), for: .normal)
        
        for (i,likelyWord) in self.likelyNextWords.enumerated() {
            self.wordButtons[i].setTitle(self.getWordText(word: likelyWord), for: .normal)
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

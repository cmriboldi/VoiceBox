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
    private struct Constants {
        static let SentenceWordCellID = "sentenceWordCell"
        static let numberOfNextWords = 5
    }
    
    // MARK: - Properties
    var synth = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string: "")
    var sentenceWordIndex = 0
    var sentence = Sentence()
    var prevWord: Word = Word(value: "")
    var currentWord: Word?
    var likelyNextWords = [Word]()
    var transitionThumbnail: UIImageView?

    @IBOutlet weak var sentenceCollectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mainWord: UIView!
    @IBOutlet var wordButtons: [UIView]!
    @IBOutlet weak var searchButton: UIView!
    
    
    // MARK: - ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = true
        }
        
        sentenceCollectionView.delegate = self
        sentenceCollectionView.dataSource = self

        if likelyNextWords.isEmpty {self.likelyNextWords = VocabDatabase.shared.getStartingWords(n: Constants.numberOfNextWords)}
        
        let searchButtonView = SearchButton(frame: searchButton.frame)
        searchButton.addSubview(searchButtonView)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.search))
        searchButton.addGestureRecognizer(tapGesture)
        
        populateWordButtons()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        sentenceCollectionView.collectionViewLayout = flowLayout
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(self.handleTap(recognizer:)))
        recognizer.delegate = self
        sentenceCollectionView.addGestureRecognizer(recognizer)
        
        deleteButton.addTarget(self, action: #selector(clearSentence(_:event:)), for: UIControlEvents.touchDownRepeat)
    }
    
    // MARK: - Actions
    @objc func wordPressed(_ sender: UITapGestureRecognizer) {
        guard let button = sender.view as? RoundedButton else {
            return
        }
        guard button.index < likelyNextWords.count else {
            return
        }
        guard let newWord = VocabDatabase.shared.getWord(withText: self.likelyNextWords[button.index].value) else {
            return
        }
        
        self.currentWord = newWord
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
        
        populateWordButtons()
        
//        for otherButton in self.wordButtons {
//            if let otherButton = otherButton as? RoundedButton, otherButton != button {
//                let buttonCenterCornerX = Double(otherButton.center.x) - Double(otherButton.bounds.width / 2)
//                let buttonCenterCornerY = Double(otherButton.center.y) - Double(otherButton.bounds.height / 2)
//                otherButton.animate(.moveTo(x: centerCornerX, y: centerCornerY))
//                otherButton.animate(.fade(way: .out)).then(.moveTo(x: buttonCenterCornerX, y: buttonCenterCornerY)).completion({
//                    if otherButton == self.wordButtons.last || otherButton == self.wordButtons.secondToLast {
//                        self.populateWordButtons(closure: {
//                            let wordChangeDelay = 0.1
//                            let showWordsDelay = 0.2
//                            button.delay(wordChangeDelay).completion({button.alpha = 0})
//                            button.delay(wordChangeDelay).then(.moveTo(x: pressedCenterCornerX, y: pressedCenterCornerY), duration: 0.0).delay(showWordsDelay).then(.fade(way: .in))
//                            for otherButton in self.wordButtons {
//                                if let otherButton = otherButton as? RoundedButton, otherButton != button {
//                                    otherButton.delay(wordChangeDelay + showWordsDelay).then(.fade(way: .in))
//                                }
//                            }
//                        })
//                    }
//                })
//            }
//        }
        
        
    }
    
    @IBAction func deleteWord(_ sender: Any) {
        if !sentence.isEmpty {
            sentenceWordIndex -= 1
            sentence.removeLast()
            let indexPath = IndexPath(row:sentenceWordIndex, section: 0)
            self.sentenceCollectionView.deleteItems(at: [indexPath])
            
            if self.sentence.count >= 1 {
                self.currentWord = Word(self.sentence[self.sentence.count - 1])
            } else {
                self.currentWord = nil
            }
            
            if self.sentence.count >= 2 {
                self.prevWord = Word(self.sentence[self.sentence.count - 2])
            } else {
                self.prevWord = Word()
            }
            
            if let currentWord = self.currentWord {
                self.likelyNextWords = NGram().nextWords(prevWord: self.prevWord, word: currentWord)
            } else {
                self.likelyNextWords = VocabDatabase.shared.getStartingWords(n: Constants.numberOfNextWords)
            }
            
            self.populateWordButtons()
        }
    }
    
    @IBAction func search(_ sender: UIButton) {
        guard let viewControllers = tabBarController?.viewControllers,
              let vocabNav = viewControllers[0] as? UINavigationController,
              let vocabViewController = vocabNav.viewControllers[0] as? VocabViewController else {
            return
        }
        
        vocabViewController.vocabulary.clear(type: "likely")
        self.likelyNextWords = self.likelyNextWords.sorted{$0.value < $1.value}
        for word in self.likelyNextWords {
            vocabViewController.vocabulary.addChild(child: VocabularyWord(name: word.value, imageName: word.imageName), parentName: "", type: "likely")
        }
        
        vocabViewController.loadNodes("")
        vocabViewController.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        vocabViewController.isSearching = false
        tabBarController?.selectedIndex = 0
    }

    // MARK: - Helper Functions
    @objc func clearSentence(_ sender: UIButton, event: UIEvent) {
        guard let touch = event.allTouches?.first else { return }
        if (touch.tapCount == 2) {
            while !sentence.isEmpty {
                sentenceWordIndex -= 1
                sentence.removeLast()
                let indexPath = IndexPath(row:sentenceWordIndex, section: 0)
                self.sentenceCollectionView.deleteItems(at: [indexPath])
            }
            
            self.currentWord = nil
            self.prevWord = Word()
            self.likelyNextWords = VocabDatabase.shared.getStartingWords(n: Constants.numberOfNextWords)
            self.populateWordButtons()
        }
    }

    func populateWordButtons(closure: (() -> Void)? = nil) {
        mainWord.subviews.forEach({ $0.removeFromSuperview() })
        if let currentWord = currentWord {
            let mainWordView = RoundedButton.init(frame: self.mainWord.frame)
            mainWordView.setTitle(currentWord.value)
            mainWord.addSubview(mainWordView)
        }
        
        for i in 0..<Constants.numberOfNextWords {
            let wordButton = self.wordButtons[i]
            wordButton.subviews.forEach({ $0.removeFromSuperview() })
            
            if i < likelyNextWords.count {
                let likelyWord = self.likelyNextWords[i]

                let buttonView = RoundedButton.init(frame: wordButton.frame, image: likelyWord.image)
                buttonView.setTitle(self.getWordText(word: likelyWord))
                
                let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(wordPressed))
                gesture.numberOfTapsRequired = 1
                buttonView.isUserInteractionEnabled = true
                buttonView.addGestureRecognizer(gesture)
                buttonView.index = i
                wordButton.addSubview(buttonView)
            }
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

    func predictNextWords(newWord: Word, numWords: Int = Constants.numberOfNextWords) -> [Word] {
        guard let currentWord = self.currentWord else {
            return []
        }
        
        self.prevWord = currentWord
        self.currentWord = newWord

        return NGram().nextWords(prevWord: self.prevWord, word: currentWord, numWords: numWords)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.SentenceWordCellID, for: indexPath)
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

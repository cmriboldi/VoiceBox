//
//  HomeViewController.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/16/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController, UINavigationControllerDelegate, GrowTransitionable {
    var triggerButtonIndex = 0
    var contentTextView = UITextView()
    @IBOutlet weak var mainStackView: UIStackView!
    var mainView: UIView {return view}
//    var mainView: UIView {return mainStackView}
    
    // MARK: - Constants
    private struct Storyboard {
        static let SentenceWordCellID = "sentenceWordCell"
    }
    
    // MARK: - Properties
    var synth = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string: "")
    var sentenceWordIndex = 0
    var sentence = Sentence()
    var textPrevWord: String = ""
    var prevWord: Word = Word(value: "", imageName: "")
    var currentWord: Word = Word(value: "", imageName: "")
    var likelyNextWords = [Word]()
    var customNavigationAnimationController = CustomNavigationAnimationController()
    var transitionThumbnail: UIImageView?

    @IBOutlet weak var sentenceCollectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mainWord: UIButton!
    @IBOutlet var wordButtons: [UIButton]!
    
    // Currently unused
    @IBOutlet weak var wordList: WordList!
    
    func getWordText(word: Word) -> String {
        if word.value == "i" {return "I"}
        return word.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = true
//            navController.delegate = transitionCoordinator
            navController.transitioningDelegate = self
        }
        
        sentenceCollectionView.delegate = self
        sentenceCollectionView.dataSource = self
        
        if likelyNextWords.isEmpty {
            likelyNextWords = VocabDatabase.shared.getStartingWords(n: 5)
        }
        
        self.mainWord.setTitle(self.getWordText(word: self.currentWord), for: .normal)
        
        for i in 0..<min(5, self.likelyNextWords.count) {
            self.wordButtons[i].setTitle(self.getWordText(word: self.likelyNextWords[i]), for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
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
    @IBAction func wordPressed(_ sender: UIButton) {
        guard sender.tag < likelyNextWords.count else {
            return
        }

        triggerButtonIndex = wordButtons.index(of: sender)!

        var newWord = self.likelyNextWords[sender.tag]
//        newWord.value = newWord.value.lowercased()
        let newScreen = HomeViewController.makeFromStoryboard()

        newScreen.currentWord = newWord
        newScreen.likelyNextWords = predictNextWords(word: newWord, numWords: 5)
        newScreen.sentence = self.sentence.copy()
        newScreen.sentenceWordIndex = self.sentenceWordIndex

        speakPhrase(newWord.spokenPhrase.lowercased())

        self.navigationController?.pushViewController(newScreen, animated: true) {
            newScreen.sentence.append(newWord)
            newScreen.sentenceCollectionView.setNeedsLayout()

            let sentenceIndexPath = IndexPath(row:self.sentenceWordIndex, section: 0)
            newScreen.sentenceCollectionView.insertItems(at: [sentenceIndexPath])
            newScreen.sentenceCollectionView.scrollToItem(at: sentenceIndexPath, at: .right, animated: true)
            newScreen.sentenceWordIndex += 1
        }

//        triggerButtonIndex = 0
        transitionThumbnail = UIImageView(image: UIImage(view: self.mainView.snapshotView(afterScreenUpdates: false)!))
    }
    
    @IBAction func deleteWord(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
//    // Currently unused
//    @IBAction func train(_ sender: UIButton) {
//        Trainer.shared.train(name: "train", extension: "txt")
//    }
    
    
    @objc func clearSentence(_ sender: UIButton, event: UIEvent) {
        let touch: UITouch = event.allTouches!.first!
        if (touch.tapCount == 2) {
            sentence.removeAll()
            sentenceWordIndex = 0
            sentenceCollectionView.reloadData()
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Helper Functions
    func speakPhrase(_ phrase: String) {
        synth = AVSpeechSynthesizer()
        utterance = AVSpeechUtterance(string: phrase)
        utterance.rate = 0.4
        synth.speak(utterance)
    }
    
    func predictNextWords(word: Word, numWords: Int) -> [Word] {
        self.textPrevWord = word.value
        self.prevWord = word
        let ngram = NGram()

        return ngram.nextWords(prevWord: self.prevWord, word: word, numWords: numWords)
    }
    
    static func makeFromStoryboard() -> HomeViewController {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            return HomeViewController()
        }
        return viewController
    }
    
    //MARK: - UINavigationControllerAnimationDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        if operation == .push {
//            // Pass the thumbnail frame to the transition animator.
//            guard let transitionThumbnail = transitionThumbnail else {return nil}//, let transitionThumbnailSuperview = transitionThumbnail.superview else { return nil }
//            customNavigationAnimationController = CustomNavigationAnimationController()
//            customNavigationAnimationController.thumbnailFrame = transitionThumbnailSuperview.convert(transitionThumbnail.frame, to: nil)
//        }
        customNavigationAnimationController = CustomNavigationAnimationController()
        customNavigationAnimationController.operation = operation
        
        return customNavigationAnimationController
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

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customNavigationAnimationController
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}

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
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    var currentWord: Word = Word(value: "")
    var topLikelyNextWords = [Word]()
    var allLikelyNextWords = [Word]()
    var transitionThumbnail: UIImageView?
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var sentenceCollectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mainWord: UIView!
    @IBOutlet var wordButtons: [UIView]!
    @IBOutlet weak var searchButton: UIView!
//    @IBAction func getImages(_ sender: Any) {
//        SearchImagesAPI.searchImages(self.currentWord.value, callback: imagesCallback)
//    }
    
    
    func initializeSentence() {
        guard let newWord = VocabDatabase.shared.getWord(withText: "") else {return}
        
        self.currentWord = newWord
        self.predictNextWords(newWord: newWord)
    }
    
    // MARK: - ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = true
        }

        sentenceCollectionView.delegate = self
        sentenceCollectionView.dataSource = self
        
//        self.currentWord = Word(value: "")

        if topLikelyNextWords.isEmpty {
//            self.topLikelyNextWords = VocabDatabase.shared.getStartingWords(n: Constants.numberOfNextWords)
            
//            guard let newWord = VocabDatabase.shared.getWord(withText: "") else {return}
//
//            self.currentWord = newWord
//            self.predictNextWords(newWord: newWord)
            self.initializeSentence()
        }
        
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
        guard button.index < topLikelyNextWords.count else {
            return
        }
        guard let newWord = VocabDatabase.shared.getWord(withText: self.topLikelyNextWords[button.index].value) else {
            return
        }
        
        select(newWord: newWord)
        
//        SearchImagesAPI.searchImages(newWord.value, callback: imagesCallback)
        
//        let pressedCenterCornerX = Double(button.center.x) - Double(button.bounds.width / 2)
//        let pressedCenterCornerY = Double(button.center.y) - Double(button.bounds.height / 2)
//        let centerCornerX = Double(mainWord.center.x) - Double(mainWord.bounds.width / 2)
//        let centerCornerY = Double(mainWord.center.y) - Double(mainWord.bounds.height / 2)
//
//        button.animate(.moveTo(x: centerCornerX, y: centerCornerY))
//
//
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
    
    func imagesCallback(returnedImage: UIImage?, word: String) {
        print("done searching img is: \(returnedImage)")
        if let image = returnedImage {
            if let data = UIImagePNGRepresentation(image) {
                let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("images/\(word).png")
                try? data.write(to: filename)
            }
        }
    }
    
    func select(newWord: Word) {
        self.prevWord = self.currentWord ?? Word.init()
        self.currentWord = newWord
        self.predictNextWords(newWord: newWord)
        
        speakPhrase(newWord.spokenPhrase?.lowercased() ?? newWord.value.lowercased())
        
        self.sentence.append(newWord)
        self.sentenceCollectionView.setNeedsLayout()
        
        let sentenceIndexPath = IndexPath(row:self.sentenceWordIndex, section: 0)
        self.sentenceCollectionView.insertItems(at: [sentenceIndexPath])
        self.sentenceCollectionView.scrollToItem(at: sentenceIndexPath, at: .right, animated: true)
        self.sentenceWordIndex += 1
        
        populateWordButtons()
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
                guard let newWord = VocabDatabase.shared.getWord(withText: "") else {return}
                self.currentWord = newWord
            }
            
            if self.sentence.count >= 2 {
                self.prevWord = Word(self.sentence[self.sentence.count - 2])
            } else {
                self.prevWord = Word()
            }
            
            self.predictNextWords(newWord: self.currentWord)
//            self.topLikelyNextWords = NGram().nextWords(prevWord: self.prevWord, word: currentWord)
//            if self.currentWord.value != "" {
//            }
//            else {
//                self.predictNextWords(newWord: self.currentWord)
//                self.topLikelyNextWords = VocabDatabase.shared.getStartingWords(n: Constants.numberOfNextWords)
//            }
//
            self.populateWordButtons()
        }
    }
    
    @IBAction func search(_ sender: UIButton) {
        guard let viewControllers = tabBarController?.viewControllers,
              let vocabNav = viewControllers[1] as? UINavigationController,
              let vocabViewController = vocabNav.viewControllers[0] as? VocabViewController else {
            return
        }
        
        vocabViewController.vocabulary.clear(type: "likely")
        self.allLikelyNextWords = self.allLikelyNextWords.sorted{$0.value < $1.value}
        print("total likely words count: \(self.allLikelyNextWords.count)")
        for word in self.allLikelyNextWords {
            vocabViewController.vocabulary.addChild(child: VocabularyWord(name: word.value, imageName: word.imageName), parentName: "", type: "likely")
        }
        
        vocabViewController.loadNodes("")
        vocabViewController.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        vocabViewController.isSearching = false
        tabBarController?.selectedIndex = 1
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
            
            
//            self.predictNextWords(newWord: self.currentWord)
//            self.currentWord = Word(value: "")
//            self.prevWord = Word()
            self.initializeSentence()
//            self.topLikelyNextWords = VocabDatabase.shared.getStartingWords(n: Constants.numberOfNextWords)
            self.populateWordButtons()
        }
    }
    
    @objc func handleMainLongPress(_ sender: UILongPressGestureRecognizer!) {
        if sender.state != .ended {return}
        
        if let indexPath = mainWord.subviews.last {
            // Get the long-pressed cell.
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {print("Could not find index path.")}
    }
    
    func populateWordButtons(closure: (() -> Void)? = nil) {
        mainWord.subviews.forEach({ $0.removeFromSuperview() })
//        if self.currentWord.value != "" {
        let mainWordView = RoundedButton.init(frame: self.mainWord.frame, image: self.currentWord.image)
        mainWordView.setTitle(self.getWordText(word: currentWord))
        mainWord.addSubview(mainWordView)
//        }
        mainWordView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleMainLongPress(_:))))
        
        for i in 0..<Constants.numberOfNextWords {
            let wordButton = self.wordButtons[i]
            wordButton.subviews.forEach({ $0.removeFromSuperview() })
            
            if i < topLikelyNextWords.count {
                let likelyWord = self.topLikelyNextWords[i]

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

    func predictNextWords(newWord: Word) {
        let currentWord = self.currentWord
        
        self.prevWord = currentWord
        self.currentWord = newWord
        
        allLikelyNextWords = NGram().nextWords(prevWord: self.prevWord, word: currentWord, numWords: -1)
        topLikelyNextWords = [Word]()
        for i in 0..<Constants.numberOfNextWords {
            if i < allLikelyNextWords.count {
                topLikelyNextWords.append(allLikelyNextWords[i])
            }
        }
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
//    //FIXME: This is broken (but I'm not sure if it's a necessary function).
//    func sendWordToFirebase(textWord: String, textNextWord: String, textNextNextWord: String) {
////        var ref: DocumentReference? = nil
////        ref = Firestore.firestore().collection("word_data").addDocument(data: [
////            "name": "Tokyo",
////            "country": "Japan"
////        ]) { err in
////            if let err = err {
////                print("Error adding document: \(err)")
////            } else {
////                print("Document added with ID: \(ref!.documentID)")
////            }
////        }
//
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let collecRef = Firestore.firestore().collection("wordData").document(uid).collection("words")
//        let docRef = collecRef.document(textWord)
//
//        var word = Word(value: textWord)
//
////        Firestore.firestore().collection("word_data").document(uid).collection("words").document(textWord).setData(wordDictionary) { err in
////            if let err = err {print("Error writing document: \(err)")}
////            else {print("Document successfully written!")}
////        }
//
//
//        docRef.getDocument { (document, error) in
//            if let document = document {
//                if document.exists{
//                    print("Document data: \(String(describing: document.data()))")
//                    guard let data = (document.data()) else {return}
//                    word = Word(value: data["value"] as! String)
//                    word.numOccur = (data["numOccur"] as! Int) + 1
//                    word.type = WordType(rawValue: "word")!
//
//                    var tempAny = data["nextWords"]
//                    var tempDictionary = data["nextWords"] as! [String:Word]
//                    word.nextWords = data["nextWords"] as? Words
//                }
//
//                if textNextWord != "" {
//                    word.addWord(value: textNextWord)
//                    if textNextNextWord != "" {
//                        word.nextWords?[textNextWord]?.addWord(value: textNextNextWord)
//                    }
//                }
//
//                var wordDictionary = ""
////                do {wordDictionary = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(word), options: []) as! [String:AnyObject]}
//                do {wordDictionary = String(data: try JSONEncoder().encode(word), encoding: String.Encoding.utf8) as String!}
//                catch let error as NSError {
//                    print("Failed to write to URL.")
//                    print(error)
//                    return
//                }
//
//                collecRef.document(textWord).setData(["object": wordDictionary]) { err in
//                    if let err = err {print("Error writing document: \(err)")}
//                    else {print("Document successfully written!")}
//                }
//            }
//        }
//    }

    private func insertWord(textWord: String, textNextWord: String, textNextNextWord: String) {
        var word = Word(value: textWord)
        let doesExist = VocabDatabase.shared.doesWordExist(withText: textWord)
        if doesExist {
            word = VocabDatabase.shared.getWord(withText: textWord)!
        }

        if textNextWord != "" {
            word.addWord(value: textNextWord)
            if textNextNextWord != "" {
                word.nextWords?[textNextWord]?.addWord(value: textNextNextWord)
            }
        }

        if doesExist {VocabDatabase.shared.update(word: word)}
        else {VocabDatabase.shared.create(word: word)}
    }

    @objc func handleTap(recognizer:UITapGestureRecognizer) {
        let spokenSentence = sentence.getSpokenSentence()
        speakPhrase(spokenSentence)
        
        var sentenceWords: [String] = []
        spokenSentence.enumerateSubstrings(in: spokenSentence.startIndex..<spokenSentence.endIndex,
                                           options: .byWords)  {
                                            (substring, _, _, _) -> () in
                                            sentenceWords.append(substring!.lowercased())
        }
        
        var textWord = ""
        var textNextWord = ""
        
        if sentenceWords.count > 0 {
            textWord = sentenceWords[0]
            if sentenceWords.count > 1 {textNextWord = sentenceWords[1]}
        }
        
        for index in 0..<sentenceWords.count {
            var textNextNextWord = ""
            if index < sentenceWords.count - 2 {textNextNextWord = sentenceWords[index+2]}
//            self.sendWordToFirebase(textWord: textWord, textNextWord: textNextWord, textNextNextWord: textNextNextWord)
            self.insertWord(textWord: textWord, textNextWord: textNextWord, textNextNextWord: textNextNextWord)
            textWord = textNextWord
            textNextWord = textNextNextWord
        }
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

// MARK: - UIImagePickerControllerDelegate
extension HomeViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let data = UIImagePNGRepresentation(pickedImage) {
                let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
                let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
                let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
                if paths.count > 0 {
                    if let dirPath = paths.first {
                        if let writePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(self.currentWord.value + "_img.png") {
                            do {try data.write(to: writePath, options: .atomic)}
                            catch let error as NSError {return}
                        }
                    }
                    self.populateWordButtons()
//                    self.sentence
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

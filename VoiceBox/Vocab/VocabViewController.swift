//
//  VocabViewController.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/17/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

final class VocabViewController: UICollectionViewController {
    // MARK: - Properties
    fileprivate let reuseIdentifier = "WordCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 5
    var largePhotoIndexPath: IndexPath? {
        didSet {
            var indexPaths = [IndexPath]()
            if let largePhotoIndexPath = largePhotoIndexPath {indexPaths.append(largePhotoIndexPath)}
            if let oldValue = oldValue {indexPaths.append(oldValue)}

            collectionView?.performBatchUpdates({
                self.collectionView?.reloadItems(at: indexPaths)
            }) {completed in
                if let largePhotoIndexPath = self.largePhotoIndexPath {self.collectionView?.scrollToItem(at: largePhotoIndexPath, at: .centeredVertically, animated: true)}
            }
        }
    }
    
    var vocabulary = Vocabulary()
    var nodes = [Node]()
    var pathTraveled = [String]()
    var isSearching = false
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBAction func goBack(_ sender: Any?) {
        if pathTraveled.count > 1 {
            pathTraveled.removeLast()
            self.loadNodes(pathTraveled.last!)
            self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    // In order to go back to the original folder structure, clear the search field and press enter.
    @IBAction func search(_ sender: Any) {
        vocabulary.clear(type: "search")
        if self.searchTextField.text! == "" {self.isSearching = false}
        else {
            self.isSearching = true
            let foundWords = VocabDatabase.shared.search(withText: self.searchTextField.text!)
            for word in foundWords {vocabulary.addChild(child: VocabularyWord(name: word.value, imageName: ""), parentName: "", type: "search")}
        }
        self.loadNodes("")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for char in "abcdefghijklmnopqrstuvwxyz" {vocabulary.addChild(child: Folder(name: String(char), imageName: ""), parentName: "")}

        self.nodes = vocabulary.getNodes(parentName: "", search: self.isSearching)
        self.pathTraveled.append("")
    }

    // MARK: - Helper Functions
    func loadNodes(_ parentName: String) {
        self.nodes = vocabulary.getNodes(parentName: parentName, search: self.isSearching)
        self.collectionView?.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension VocabViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.nodes.count
    }
    
    func nodeToImage(node: Node, size: CGSize) -> UIImage {
        let word = node.name
        let baseSize = word.boundingRect(with: CGSize(width: 2048, height: 2048), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: size.height / 2)], context: nil).size
        let fontSize = size.width / max(baseSize.width, baseSize.height) * (size.width / 2)
        let font = UIFont.systemFont(ofSize: fontSize)
        let textSize = word.boundingRect(with: CGSize(width: size.width, height: size.height), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        style.lineBreakMode = NSLineBreakMode.byClipping
        
        let attr: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: font, NSAttributedStringKey.paragraphStyle: style, NSAttributedStringKey.backgroundColor: UIColor.clear]
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        word.draw(in: CGRect(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2, width: textSize.width, height: textSize.height), withAttributes: attr)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let imageView = UIImageView(image: image)
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.clipsToBounds = true
        if let _ = node as? Folder {imageView.layer.cornerRadius = imageView.bounds.width / 2}
        
        return UIImage(view: imageView)
    }

    @objc func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView?.indexPathForItem(at: location)

        if let index = indexPath {
            if let node = self.nodes[index.item] as? Folder {
                let loadedWords = VocabDatabase.shared.getWords(withPrefix: node.name)
                
                for word in loadedWords {
                    if vocabulary.findWord(word: word.value, parent: self.pathTraveled[self.pathTraveled.count - 1]) == "" {
                        vocabulary.addChild(child: VocabularyWord(name: word.value, imageName: ""), parentName: node.name)
                    }
                }
                
                self.pathTraveled.append(node.name)
                self.loadNodes(node.name)
                self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
            else {
                let homeViewController = (tabBarController?.viewControllers![1] as! UINavigationController).viewControllers[0] as! HomeViewController
                
                let node = self.nodes[index.item] as! VocabularyWord
                
                homeViewController.prevWord = Word(value: "")
                homeViewController.currentWord = VocabDatabase.shared.getWord(withText: node.name)!
                homeViewController.likelyNextWords = NGram().nextWords(prevWord: homeViewController.prevWord, word: homeViewController.currentWord)
                homeViewController.speakPhrase(homeViewController.currentWord.spokenPhrase?.lowercased() ?? homeViewController.currentWord.value.lowercased())
                homeViewController.sentence.append(homeViewController.currentWord)
                homeViewController.sentenceCollectionView.setNeedsLayout()
                
                let sentenceIndexPath = IndexPath(row:homeViewController.sentenceWordIndex, section: 0)
                homeViewController.sentenceCollectionView.insertItems(at: [sentenceIndexPath])
                homeViewController.sentenceCollectionView.scrollToItem(at: sentenceIndexPath, at: .right, animated: true)
                homeViewController.sentenceWordIndex += 1
                
                homeViewController.populateWordButtons()
                
                tabBarController?.selectedIndex = 1
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        super.collectionView(collectionView, cellForItemAt: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! WordCell
        cell.backgroundColor = UIColor.white
        
        var image: UIImage? = nil
        let cellNode = self.nodes[(indexPath as IndexPath).item]
        if cellNode.imageName != "" {image = UIImage(named: cellNode.imageName)!}
        else {image = nodeToImage(node: cellNode, size: cellNode.getImageSize())}
        cell.imageView.image = image

        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))

        return cell
    }
}

extension VocabViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath == largePhotoIndexPath {
            let wordImage = UIImage(named: self.nodes[(indexPath as IndexPath).item].imageName)
            var size = collectionView.bounds.size
            size.height -= topLayoutGuide.length
            size.height -= (sectionInsets.top + sectionInsets.right)
            size.width -= (sectionInsets.left + sectionInsets.right)
            
            let imageSize = wordImage?.size
            var returnSize = size
            
            let aspectRatio = imageSize!.width / imageSize!.height
            returnSize.height = returnSize.width / aspectRatio
            
            if returnSize.height > size.height {
                returnSize.height = size.height
                returnSize.width = size.height * aspectRatio
            }
            
            return returnSize
        }

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

// MARK: - UICollectionViewDelegate
extension VocabViewController {
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        largePhotoIndexPath = largePhotoIndexPath == indexPath ? nil : indexPath
        return false
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

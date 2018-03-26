//
//  VocabViewController.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/17/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

final class VocabViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    let imagePicker = UIImagePickerController()
    var currentNode: Node? = nil

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBAction func goBack(_ sender: Any?) {
        if self.isSearching {
            vocabulary.clear(type: "search")
            self.isSearching = false
            self.searchTextField.text = ""
            self.loadNodes("")
        }
        else if pathTraveled.count > 1 {
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
//            var foundWords = VocabDatabase.shared.getWords(withPrefix: self.searchTextField.text!)
            let foundWords = VocabDatabase.shared.getWords(withSubstring: self.searchTextField.text!).sorted{$0.value < $1.value}
            for word in foundWords {vocabulary.addChild(child: VocabularyWord(name: word.value, imageName: ""), parentName: "", type: "search")}
        }
        self.loadNodes("")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
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

    @objc func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView?.indexPathForItem(at: location)

        if let index = indexPath {
            if let node = self.nodes[index.item] as? Folder {
                let loadedWords = VocabDatabase.shared.getWords(withPrefix: node.name).sorted{$0.value < $1.value}
                
                for word in loadedWords {
                    if vocabulary.findWord(word: word.value, parent: self.pathTraveled[self.pathTraveled.count - 1]) == "" {
                        vocabulary.addChild(child: VocabularyWord(name: word.value, imageName: ""), parentName: node.name)
                    }
                }
                
                self.pathTraveled.append(node.name)
                self.loadNodes(node.name)
                self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            } else {
                guard let tabBarController = self.tabBarController,
                      let tabVCs = tabBarController.viewControllers,
                      let homeNameVC = tabVCs[1] as? UINavigationController,
                      let homeViewController = homeNameVC.viewControllers[0] as? HomeViewController else {
                    return
                }
                guard let node = self.nodes[index.item] as? VocabularyWord else {
                    return
                }
                guard let currentWord = homeViewController.currentWord else {
                    return
                }
                guard let newCurrentWord = VocabDatabase.shared.getWord(withText: node.name), let newSpokenPhrase = currentWord.spokenPhrase else {
                    return
                }
                
                homeViewController.prevWord = Word(value: "")
                homeViewController.currentWord = newCurrentWord
                homeViewController.likelyNextWords = NGram().nextWords(prevWord: homeViewController.prevWord, word: newCurrentWord)
                homeViewController.speakPhrase(newSpokenPhrase.lowercased())
                homeViewController.sentence.append(newCurrentWord)
                homeViewController.sentenceCollectionView.setNeedsLayout()
                
                let sentenceIndexPath = IndexPath(row:homeViewController.sentenceWordIndex, section: 0)
                homeViewController.sentenceCollectionView.insertItems(at: [sentenceIndexPath])
                homeViewController.sentenceCollectionView.scrollToItem(at: sentenceIndexPath, at: .right, animated: true)
                homeViewController.sentenceWordIndex += 1
                homeViewController.populateWordButtons()

                self.isSearching = false
                self.loadNodes("")
                self.searchTextField.text = ""

                self.tabBarController?.selectedIndex = 1
            }
        }
    }

    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer!) {
//        if self.nodes[(self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView))?.item)!] is Folder {return}
        if sender.state != .ended {return}
        
        let location = sender.location(in: self.collectionView)
        if let indexPath = self.collectionView?.indexPathForItem(at: location) {
            // Get the long-pressed cell
//            self.currentCell = self.collectionView?.cellForItem(at: indexPath) as! WordCell
            self.currentNode = self.nodes[indexPath.item]
            
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            
//            imagePicker.modalPresentationStyle = .popover
            self.present(imagePicker, animated: true, completion: nil)
//            imagePicker.popoverPresentationController?.barButtonItem = cell
        }
        else {print("Could not find index path.")}
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        super.collectionView(collectionView, cellForItemAt: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! WordCell
        cell.backgroundColor = UIColor.white
        var node = self.nodes[(indexPath as IndexPath).item]
        
        cell.imageView.image = node.getImage()

        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))

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

// MARK: - UIImagePickerControllerDelegate
extension VocabViewController {
//    func fetchLastImage(completion: (localIdentifier: String?) -> Void) {
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        fetchOptions.fetchLimit = 1
//
//        let fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions)
//        if (fetchResult.firstObject != nil) {
//            let lastImageAsset: PHAsset = fetchResult.firstObject as! PHAsset
//            completion(localIdentifier: lastImageAsset.localIdentifier)
//        }
//        else {completion(localIdentifier: nil)}
//    }
    
//    func getStringPathTraveled() -> String {
//        var path = ""
//        for folder in self.pathTraveled {path.append("/" + folder)}
//        return path
//    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let data = UIImagePNGRepresentation(pickedImage) {
//                data = data as Data
//                let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//                let filename = documentDirURL.appendingPathComponent((self.currentNode?.name)!).appendingPathExtension("png")

                let user = Auth.auth().currentUser
//                let imageRef = Storage.storage().reference(withPath: "images/" + (user?.uid)! + "/" + (self.currentNode?.name)! + ".png")
                self.currentNode?.setImage(image: pickedImage)

                // Create a root reference
                let storageRef = Storage.storage().reference()
                
//                // Create a reference to "mountains.jpg"
//                let wordRef = storageRef.child((self.currentNode?.name)! + ".png")
                
                
                // Create a reference to the image location
//                let wordImagesRef = storageRef.child((user?.uid)! + "/images/" + (self.currentNode?e.name)! + ".png")
                // Create a reference to the image location

                var path = "images/"
                path.append((user?.uid)!)
                path.append("/")
                path.append((self.currentNode?.getType())!)
                path.append("/")
                path.append((self.currentNode?.name)!)
                path.append(".png")
//                path.append(uid).append("/").append(type).append("/").append(name).append(".png")
                let wordImagesRef = Storage.storage().reference(withPath: path)
                
                // Upload the file to the correct location
                let _ = wordImagesRef.putData(data, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        print("Uh-oh, an error occurred! \(String(describing: error))")
                        return
                    }
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    let downloadURL = metadata.downloadURL
                    self.collectionView?.reloadData()
                }

//                var uid = user?.uid
//                db.collection("images").document((user?.uid)!).setData([
//                var temp = data.base64EncodedString()
//                var len = temp.count
//                Firestore.firestore().collection("images").document((user?.uid)!).setData([
////                    (self.currentNode?.name)!: ["data": data as NSData, "type": "VocabularyWord"],
//                    (self.currentNode?.name)!: ["data": temp, "type": "VocabularyWord"]
//                ]) { err in
//                    if let err = err {print("Error writing document: \(err)")}
//                    else {print("Document successfully written!")}
//                }
//                self.collectionView?.reloadData()
            }
        }
        dismiss(animated: true, completion: nil)
    }

//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
////            self.currentNode.imageView.contentMode = .scaleAspectFit
////            self.currentNode.imageView.image = pickedImage
//
//            if let data = UIImagePNGRepresentation(pickedImage) {
//                let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//                let filename = documentDirURL.appendingPathComponent((self.currentNode?.name)!).appendingPathExtension(".png")
//                try? data.write(to: filename)
//
//                self.currentNode?.setImageName(imageName: filename.absoluteString)
//                self.collectionView?.reloadData()
//            }
//        }
//
//        dismiss(animated: true, completion: nil)
//    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

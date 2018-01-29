//
//  Trie.swift
//  
//
//  Created by Andrew Hale on 1/28/18.
//

import Foundation

private class TrieNode {
    var value: Character
    weak var parentNode: TrieNode?
    var nextWords = [String: Int]()
    var children = [Character: TrieNode]()
    var isLeaf: Bool {return children.count == 0}
    
    /// Initializes a node.
    ///
    /// - Parameters:
    ///   - value: The value that goes into the node
    ///   - parentNode: A reference to this node's parent
    init(value: Character? = "-", parentNode: TrieNode? = nil) {
        self.value = value!
        self.parentNode = parentNode
    }
    
    /// Adds a child node to self.  If the child is already present,
    /// do nothing.
    ///
    /// - Parameter value: The item to be added to this node.
    func add(value: Character) {
        guard children[value] == nil else {
            return
        }
        children[value] = TrieNode(value: value, parentNode: self)
    }
}

public class Trie {
    /// The number of words in the trie
    public var count: Int {return wordCount}
    /// Is the trie empty?
    public var isEmpty: Bool {return wordCount == 0}
    /// All words currently in the trie
    public var words: [String]
    private let root: TrieNode
    private var wordCount: Int
    
    /// Creates an empty trie.
    public init() {
        root = TrieNode()
        wordCount = 0
        words = [String]()
    }
    
    // MARK: NSCoding
    /// Initializes the trie with words from an archive
    ///
    /// - Parameter decoder: Decodes the archive
    required convenience public init?(textFilePath: String) {
        self.init()
        
        var textFile: String = ""
        
        do {textFile = try NSString.init(contentsOfFile: textFilePath, encoding: String.Encoding.utf8.rawValue) as String}
        catch {/* error handling here */}
        
        self.words = [String]()
        textFile.enumerateSubstrings(in: textFile.startIndex..<textFile.endIndex,
                                     options: .byWords) {
                                        (substring, _, _, _) -> () in
                                        self.words.append(substring!.lowercased())
                                    }
        
        for (index, word) in self.words.enumerated() {
            var nextWord = ""
            if index < self.words.count - 1 {
                nextWord = self.words[index + 1]
            }
            self.insert(word: word, nextWord: nextWord)
        }
    }
}

extension Trie {
    public func insert(word: String, nextWord: String) {
        guard !word.isEmpty else {return}
        
        var currentNode = root
        
        for character in word.characters {
            if let childNode = currentNode.children[character] {currentNode = childNode}
            else {
                currentNode.add(value: character)
                currentNode = currentNode.children[character]!
            }
        }
        
        if currentNode.nextWords[nextWord] != nil {currentNode.nextWords[nextWord]! += 1}
        else {currentNode.nextWords[nextWord] = 1}
        
        // Word already present?
        guard currentNode.nextWords.count == 0 else {
            return
        }
        
        wordCount += 1
        words.append(word)
    }
    
    public func nextWords(word: String) -> [String: Int] {
        guard !word.isEmpty else {
            return [:]
        }
        var currentNode = root
        for character in word.characters {
            guard let childNode = currentNode.children[character] else {return [:]}
            currentNode = childNode
        }
        return currentNode.nextWords
    }
}

//
//  NgramCounter.swift
//  LangKit
//
//  Created by Richard Wei on 4/12/16.
//
//
//  NgramCounter protocol definition.
//
//  TrieNgramCounter and FastTrieNgramCounter are wrappers for Trie<K> and FastTrie<K>.
//  Before Swift supports protocol conformance with generic constraints, this is the
//  only way of making Trie<K> and FastTrie<K> conform to NgramCounter.
//

public protocol NgramCounter {

    mutating func insert(_ ngram: [String])

    subscript(ngram: [String]) -> Int { get }

    func contains(ngram: [String]) -> Bool

    var count: Int { get }

}

public struct TrieNgramCounter : NgramCounter {

    private var trie: Trie<String>

    public init() {
        trie = Trie()
    }

    public mutating func insert(_ ngram: [String]) {
        trie = trie.insert(ngram, incrementingNodes: true)
    }

    public subscript(ngram: [String]) -> Int {
        return trie.count(ngram)
    }

    public func contains(ngram: [String]) -> Bool {
        return trie.count(ngram) != 0
    }

    public var count: Int {
        return trie.count
    }
    
}

private func ==(lhs: DictionaryNgramCounter.NgramKey, rhs: DictionaryNgramCounter.NgramKey) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public struct DictionaryNgramCounter : NgramCounter {

    private struct NgramKey: Hashable  {
        let ngram: [String]
        let hashValue: Int
        init(_ ngram: [String]) {
            self.ngram = ngram
            hashValue = ngram.reduce(0) { acc, x in
                31 &* acc.hashValue &+ x.hashValue
            }
        }
    }

    private var total: Int = 0
    private var table: [NgramKey: Int]
    private var backoffTable: [NgramKey: Int]
    private let minimumCount: Int

    public init(minimumCapacity capacity: Int, minimumCount: Int = 1) {
        table = .init(minimumCapacity: capacity)
        backoffTable = .init(minimumCapacity: capacity)
        self.minimumCount = minimumCount
    }

    public init() {
        self.init(minimumCapacity: 4096)
    }

    public mutating func insert(_ ngram: [String]) {
        let key = NgramKey(ngram)
        let pregramKey = NgramKey(!!ngram.dropLast())
        table[key] ?+= 1
        backoffTable[pregramKey] ?+= 1
        total += 1
    }

    public subscript(ngram: [String]) -> Int {
        if ngram.isEmpty {
            return total // Unigram precount
        }
        let key = NgramKey(ngram)
        return table[key] ?? backoffTable[key] ?? minimumCount
    }

    public func contains(ngram: [String]) -> Bool {
        let key = NgramKey(ngram)
        return table[key] ?? backoffTable[key] != nil
    }

    public var count: Int {
        return total
    }

}

public struct FastTrieNgramCounter : NgramCounter {

    var root: FastTrie<String>

    public init() {
        root = FastTrie()
    }

    public mutating func insert(_ ngram: [String]) {
        root.insert(ngram, incrementingNodes: true)
    }

    public subscript(ngram: [String]) -> Int {
        return root.count(ngram)
    }

    public func contains(ngram: [String]) -> Bool {
        return root.count(ngram) != 0
    }

    public var count: Int {
        return root.count()
    }

}

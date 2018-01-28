//
//  FastTrie.swift
//  LangKit
//
//  Created by Richard Wei on 4/23/16.
//
//

/// Fast mutable trie
public struct FastTrie<K: Hashable> {
    private var key: K!
    private var count: Int = 0
    public private(set) var value: Float?
    public private(set) var children: [K: FastTrie<K>]?
    public private(set) var isLeaf: Bool = true

    /// Initialize leaf
    public init(rootKey: K? = nil,
                inserting initialItem: [K]? = nil,
                value: Float? = nil,
                incrementingNodes incrementing: Bool = false) {
        self.key = rootKey
        if let initialItem = initialItem {
            self.insert(initialItem, value: value, incrementingNodes: incrementing)
        }
    }
}

// MARK: - Equatable conformance
extension FastTrie : Equatable {}

private func ==<T>(lhs: [T: FastTrie<T>]?, rhs: [T: FastTrie<T>]?) -> Bool {
    return lhs == rhs
}

public func ==<T>(lhs: FastTrie<T>, rhs: FastTrie<T>) -> Bool {
    return lhs.key == rhs.key
        && lhs.count == rhs.count
        && lhs.children == rhs.children
        && lhs.isLeaf == rhs.isLeaf
}

// MARK: - Insertion
public extension FastTrie {

    public mutating func insert(_ item: [K], value: Float? = nil, incrementingNodes incrementing: Bool) {
        // Base case
        if item.isEmpty {
            self.count += 1
            self.value = value
            return
        }

        let nk = item.first!
        let restItem = !!item.dropFirst()
        if incrementing { count += 1 }

        if isLeaf {
            self.isLeaf = false
            self.children = [nk: FastTrie(rootKey: nk, inserting: restItem, value: value, incrementingNodes: incrementing)]
            return
        }

        // Node
        // Child exists
        if let _ = children?[nk] {
            children![nk]!.insert(restItem, value: value, incrementingNodes: incrementing)
        }

        // Child does not exist. Call insert on a new leaf
        else {
            children![nk] = FastTrie(rootKey: nk, inserting: restItem, value: value, incrementingNodes: incrementing)
        }
    }

}

// MARK: - Query
public extension FastTrie {

    public func count(_ item: [K] = []) -> Int {
        // Base case
        if item.isEmpty {
            return count
        }

        let nk = item.first!
        guard let child = children?[nk] else {
            return 0
        }
        return child.count(!!item.dropFirst())
    }

    public func search(_ item: [K] = []) -> Float? {
        // Base case
        if item.isEmpty {
            return value
        }
        let nk = item.first!
        guard let child = children?[nk] else {
            return 0
        }
        return child.search(!(!item.dropFirst()))
    }

}

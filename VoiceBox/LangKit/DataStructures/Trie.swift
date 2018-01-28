//
//  Trie.swift
//  LangKit
//
//  Created by Richard Wei on 4/3/16.
//
//

/// Trie data structure (immutable)
///
/// - Leaf: (key, count)
/// - Node: (key, count, children)
public enum Trie<K: Hashable> {

    case leaf(K!, Int)
    indirect case node(K!, Int, [K: Trie<K>])

    public init(initial: [K]? = nil) {
        let base = Trie.leaf(nil, 0)
        self = initial == nil ? base : base.insert(initial!)
    }

}

// MARK: - Equatable conformance
extension Trie : Equatable {}

/// Equate two tries
/// 
/// - parameter lhs: Trie
/// - parameter rhs: Trie
/// 
/// - returns: Equal or not
public func ==<K>(lhs: Trie<K>, rhs: Trie<K>) -> Bool {
    switch (lhs, rhs) {
    case (.leaf(let k1, let v1), .leaf(let k2, let v2)):
        return k1 == k2 && v1 == v2
    case (.node(let k1, let v1, let c1), .node(let k2, let v2, let c2)):
        return k1 == k2 && v1 == v2 && c1 == c2
    default:
        return false
    }
}

/// Match type of two tries
/// 
/// - parameter lhs: Trie
/// - parameter rhs: Trie
/// 
/// - returns: Match or not
public func ~=<K>(lhs: Trie<K>, rhs: Trie<K>) -> Bool {
    switch (lhs, rhs) {
    case (.leaf(_, _)   , .leaf(_, _)   ),
         (.node(_, _, _), .node(_, _, _)):
        return true
    default:
        return false
    }
}

/// Combine two tries
/// 
/// - parameter lhs: Left trie
/// - parameter rhs: Rigth trie
/// 
/// - returns: New trie
public func +<K>(lhs: Trie<K>, rhs: Trie<K>) -> Trie<K> {
    return lhs.unionLeft(rhs)
}

// MARK: - Insertion
public extension Trie {

    /// Return a new trie with an item sequence inserted
    ///
    /// - parameter item: item sequence
    ///
    /// - returns: New trie after insertion
    public func insert(_ item: [K], incrementingNodes incr: Bool = false) -> Trie<K> {
        switch self {

        // Base cases
        case .leaf(let k, let v) where item.isEmpty:
            return .leaf(k, v + 1)

        case .node(let k, let v, let children) where item.isEmpty:
            return .node(k, v + 1, children)

        // Leaf
        case .leaf(let k, let v):
            let nk = item.first!
            let child = Trie.leaf(nk, 0).insert(!!item.dropFirst(), incrementingNodes: incr)
            return .node(k, incr ? v + 1 : v, [nk : child])

        // Node
        case .node(let k, let v, var children):
            let nk = item.first!
            let restItem = !!item.dropFirst()
            // Child exists
            if let child = children[nk] {
                children[nk] = child.insert(restItem, incrementingNodes: incr)
            }
            // Child does not exist. Call insert on a new leaf
            else {
                children[nk] = Trie.leaf(nk, 0).insert(restItem, incrementingNodes: incr)
            }
            return .node(k, incr ? v + 1 : v, children)
        }

    }

}

// MARK: - Combination
public extension Trie {

    /// Returns a union of two tries
    ///
    /// - parameter other:            Other trie
    /// - parameter conflictResolver: Conflict resolving function
    ///
    /// - returns: New trie after union
    public func union(_ other: Trie<K>, conflictResolver: @noescape (K, K) -> K?) -> Trie<K> {
        // TODO
        return self
    }

    /// Returns a union of two tries
    /// If there's a conflict, take the original (left)
    ///
    /// - parameter other: Other trie
    ///
    /// - returns: New trie after union
    public func unionLeft(_ other: Trie<K>) -> Trie<K> {
        return union(other) {left, _ in left}
    }

    /// Returns a union of two tries
    /// If there's a conflict, take the new (right)
    ///
    /// - parameter other: Other trie
    ///
    /// - returns: New trie after union
    public func unionRight(_ other: Trie<K>) -> Trie<K> {
        return union(other) {_, right in right}
    }

}

// MARK: - Predication and Cardinality
public extension Trie {

    /// Determine if the key exists in children
    ///
    /// - parameter key: Key
    ///
    /// - returns: Exists or not
    public func hasChild(_ key: K) -> Bool {
        guard case .node(_, _, let children) = self else {
            return false // Leaf has no children
        }
        return children.keys.contains(key)
    }

    /// Number of children
    public var childCount: Int {
        guard case .node(_, _, let children) = self else {
            return 0 // Leaf has no children
        }
        return children.count
    }

}

// MARK: - Calculation
public extension Trie {

    /// Count at current node or leaf
    public var count: Int {
        return self.count([])
    }

    /// Count item sequence
    ///
    /// - parameter item: Item sequence
    ///
    /// - returns: Count of sequence
    public func count(_ item: [K]) -> Int {
        switch self {
        // Base case
        case .leaf(_, let v):
            return item.isEmpty ? v : 0
        // Node
        case .node(_, let v, let children):
            if item.isEmpty {
                return v
            }
            let nk = item.first!
            guard let child = children[nk] else {
                return 0
            }
            return child.count(item.dropFirst().map{$0})
        }
    }

    /// Sum all leave counts
    ///
    /// - returns: Count
    public func sumLeaves() -> Int {
        switch self {
        case .leaf(_, let v):
            return v
        case .node(_, _, let children):
            let sums = children.values.map{$0.sumLeaves()}
            return sums.reduce(sums.first!, combine: +)
        }
    }

    /// Sum all counts
    ///
    /// - returns: Count
    public func sum() -> Int {
        switch self {
        case .leaf(_, let v):
            return v
        case .node(_, let v, let children):
            let sums = children.values.map{$0.sum()}
            return v + sums.reduce(sums.first!, combine: +)
        }
    }

}


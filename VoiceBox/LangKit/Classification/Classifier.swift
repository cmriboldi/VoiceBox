//
//  Classifier.swift
//  LangKit
//
//  Created by Richard Wei on 3/22/16.
//
//

/// Argument extremum by comparison on keys
///
/// - parameter compare: Comparison function
/// - parameter keyFunc: Key function
/// - parameter args:    Arguments
///
/// - returns: Extremum
public func argext<T, K: Comparable>(_ args: [T], compare: (K, K) -> Bool, keyFunc: T -> K) -> T? {
    return args.first >>- { args.reduce($0, combine: { compare(keyFunc($0), keyFunc($1)) ? $0 : $1 } ) }
}

/// Argument extremum function provider
///
/// - parameter compFunc: Comparison function
///
/// - returns: Argument extremum function that uses comparison function
public func argext<T, K: Comparable>(_ compare: (K, K) -> Bool) -> ([T], T -> K) -> T? {
    return { args, keyFunc in argext(args, compare: compare, keyFunc: keyFunc) }
}

/// Argument maximum
///
/// - parameter keyFunc: Key function
/// - parameter args:    Arguments
///
/// - returns: Argument maximum
public func argmax<T, K : Comparable>(_ args: [T], keyFunc: T -> K) -> T? {
    return argext(args, compare: >, keyFunc: keyFunc)
}

/// Argument minimum
///
/// - parameter keyFunc: Key function
/// - parameter args:    Arguments
///
/// - returns: Argument minimum
public func argmin<T, K : Comparable>(_ args: [T], keyFunc: T -> K) -> T? {
    return argext(args, compare: <, keyFunc: keyFunc)
}

/// Classifier protocol which each classifier conforms to
public protocol Classifier {

    associatedtype Input
    associatedtype Label: Hashable

    var classes: [Label] { get }

    func classify(_ input: Input) -> Label?

}

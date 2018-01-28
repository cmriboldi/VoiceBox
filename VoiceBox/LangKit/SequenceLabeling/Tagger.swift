//
//  Tagger.swift
//  LangKit
//
//  Created by Richard Wei on 4/14/16.
//
//

public protocol Tagger {
    /// Tag a sequence
    ///
    /// - parameter sequence: Sequence of items [w0, w1, w2, ...]
    ///
    /// - returns: [(w0, t0), (w1, t1), (w2, t2), ...]
    func tag(_ sequence: [String]) -> [(String, String)]

}

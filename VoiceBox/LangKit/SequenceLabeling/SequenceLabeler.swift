//
//  SequenceLabeler.swift
//  LangKit
//
//  Created by Richard Wei on 3/20/16.
//  Copyright © 2016 Richard Wei. All rights reserved.
//

public protocol SequenceLabelingModel {

    associatedtype Item
    associatedtype Label

    /// Train from tagged corpus
    ///
    /// - parameter taggedCorpus: Tagged corpus [[(w0, t0), (w1, t1), ...], [(w0, t0), (w1, t1), ...], ...]
    mutating func train<C: Sequence where C.Iterator.Element == [(Item, Label)]>(labeledSequences sequences: C)

    /// Tag a sequence
    ///
    /// - parameter sequence: Sequence of items [w0, w1, w2, ...]
    ///
    /// - returns: [(w0, t0), (w1, t1), (w2, t2), ...]
    func tag(_ sequence: [Item]) -> [(Item, Label)]

}

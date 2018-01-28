//
//  Aligner.swift
//  LangKit
//
//  Created by Richard Wei on 3/23/16.
//
//

public protocol Aligner {

    typealias SentenceTuple = ([String], [String])

    /// Initialize a model with a parallel corpus
    ///
    /// - parameter bitext: tokenized parallel corpus
    init(bitext: [SentenceTuple])

    /// Train model iteratively
    ///
    /// - parameter iterations: number of iterations of EM algorithm
    func train<S: Sequence where S.Iterator.Element == SentenceTuple>(bitext: S, iterations: Int)

    /// Align two sentences
    ///
    /// - parameter fSentence: source sentence
    /// - parameter eSentence: destination sentence
    ///
    /// - returns: Alignment dictionary
    func align(fSentence: [String], eSentence: [String]) -> [Int: Int]

}

extension Aligner {

    ///	Find alignment indices for parallel corpora
    ///
    ///	- parameter bitext:	Parallel corpora
    ///
    ///	- returns: Corpus of alignment index tuples
    public func alignmentIndices<S: Sequence where S.Iterator.Element == SentenceTuple>(bitext: S) -> [[(Int, Int)]] {
        var indices: [[(Int, Int)]] = []
        for (f, e) in bitext {
            let alignment = align(fSentence: f, eSentence: e)
            indices.append(alignment.sorted(isOrderedBefore: {$0.0 < $1.0}).map{$0})
        }
        return indices
    }
}

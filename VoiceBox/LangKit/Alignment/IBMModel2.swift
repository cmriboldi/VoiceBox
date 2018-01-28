//
//  IBMModel2.swift
//  LangKit
//
//  Created by Richard Wei on 3/21/16.
//  Copyright © 2016 Richard Wei. All rights reserved.
//

public final class IBMModel2 : IBMModel1 {

    typealias WordKey = ArrayKey<String>
    typealias AlignKey = ArrayKey<Int>

    // Alignment probabilities
    var alignment: [AlignKey: Float]

    // Alignment key probablizer
    private func probablize(_ key: AlignKey) -> Float {
        return 1.0 / (Float(key[3]) + 1.0)
    }

    /// Initialize Model 2 from parallel corpora
    ///
    /// - parameter bitext:    Parallel corpora
    /// - parameter threshold: Probability threshold for Model 1 training
    public override init<S: Sequence where S.Iterator.Element == SentenceTuple>(bitext: S, probabilityThreshold threshold: Float) {
        self.alignment = [:]
        super.init(bitext: bitext, probabilityThreshold: threshold)
        train(bitext: bitext)
    }

    /// Train Model 2 from parallel corpora
    ///
    /// - parameter bitext:     Parallel corpora
    /// - parameter iterations: Number of iterations
    public override func train<S: Sequence where S.Iterator.Element == SentenceTuple>(bitext: S, iterations: Int = 100) {
        self.train(bitext: bitext, lexicalIterations: iterations, alignmentIterations: iterations)
    }

    /// Train Model 2 by specifying iterations for lexical training and alignment training
    ///
    /// - parameter bitext:       Parallel corpora
    /// - parameter m1Iterations: Lexical iterations
    /// - parameter m2Iterations: Alignment iterations
    public func train<S: Sequence where S.Iterator.Element == SentenceTuple>
                      (bitext: S, lexicalIterations m1Iterations: Int, alignmentIterations m2Iterations: Int) {
        // Argument `bitext` as a Sequence will be potentially desructively iterated twice
        // So we want to convert it to a collection
        let bitext = !!bitext

        // Train Model 1 (super)
        super.train(bitext: bitext, iterations: m1Iterations)

        // Train Model 2 (self)
        // Initialize
        var count: [WordKey: Float] = [:]
        var total: [String: Float] = [:]
        var countA: [AlignKey: Float] = [:]
        var totalA: [AlignKey: Float] = [:]
        var sTotal: [String: Float] = [:]

        /// EM algorithm
        for _ in 1...m2Iterations {
            // Re-initialize
            count.removeAll(keepingCapacity: true)
            total.removeAll(keepingCapacity: true)
            countA.removeAll(keepingCapacity: true)
            totalA.removeAll(keepingCapacity: true)

            for (f, e) in bitext {
                let (lf, le) = (f.count, e.count)

                // Compute normalization
                sTotal.removeAll(keepingCapacity: true)
                for (j, ej) in e.enumerated() {
                    sTotal[ej] = 0
                    for (i, fi) in f.enumerated() {
                        let key: AlignKey = [i, j, le, lf]
                        sTotal[ej] = sTotal[ej]! +
                                     (trans[[ej, fi]] ?? initialTrans) *
                                     (alignment[key] ?? probablize(key))
                    }
                }
                // Collect counts
                for (j, ej) in e.enumerated() {
                    for (i, fi) in f.enumerated() {
                        let key: AlignKey = [i, j, le, lf]
                        let totalKey: AlignKey = [j, le, lf]
                        let wordPair: WordKey = [ej, fi]
                        let c = (trans[wordPair] ?? initialTrans) *
                                (alignment[key] ?? probablize(key)) /
                                (sTotal[ej] ?? 0.0)
                        count[wordPair] = (count[wordPair] ?? 0.0) + c
                        total[fi] = (total[fi] ?? 0.0) + c
                        countA[key] = (countA[key] ?? 0.0) + c
                        totalA[totalKey] = (totalA[totalKey] ?? 0.0) + c
                    }
                }
            }
            // Estimate probabilities
            for pair in count.keys {
                self.trans[pair] = count[pair]! / total[pair[1]]!
            }
            for alignmentKey in countA.keys {
                let totalKey: AlignKey = [alignmentKey[1], alignmentKey[2], alignmentKey[3]]
                self.alignment[alignmentKey] = countA[alignmentKey]! / totalA[totalKey]!
            }
        }
    }

    /// Compute alignment for a sentence pair
    ///
    /// - parameter eSentence: source tokenized sentence
    /// - parameter fSentence: destination tokenized sentence
    ///
    /// - returns: alignment dictionary
    public override func align(fSentence: [String], eSentence: [String]) -> [Int: Int] {
        let (lf, le) = (fSentence.count, eSentence.count)
        var vitAlignment = [Int: Int]()
        for (j, ej) in eSentence.enumerated() {
            var (maxI, maxP): (Int, Float) = (0, -1.0)
            for (i, fi) in fSentence.enumerated() {
                let t = trans[[ej, fi]] ?? initialTrans
                let alignmentKey: AlignKey = [i, j, le, lf]
                let a = alignment[alignmentKey] ?? probablize(alignmentKey)
                let p = t * a
                if maxP < p {
                    (maxI, maxP) = (i, p)
                }
            }
            vitAlignment[j] = maxI
        }
        return vitAlignment
    }

}

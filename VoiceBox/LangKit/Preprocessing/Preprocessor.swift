//
//  NgramModel.swift
//  LangKit
//
//  Created by Richard Wei on 3/20/16.
//  Copyright © 2016 Richard Wei. All rights reserved.
//

// Token replacements for preprocessing
internal let unknown = "<unk>"
internal let sentenceStart = "<s>"
internal let sentenceEnd = "</s>"

extension Sequence where Iterator.Element == String {

    /// Wrap <s> and </s> symbols around a tokenized sentence
    /// Complexity: O(1)
    ///
    /// - returns: [<s>, token1, token2, ..., </s>]
    public func wrapSentenceBoundary() -> [String] {
        return [sentenceStart] + self + [sentenceEnd]
    }

    /// Replace rare tokens in a array of tokens
    /// Complexity: O(n)
    ///
    /// - parameter minimumCount: Minimum count of a token in order not to be replaced with <unk>
    ///
    /// - returns: Array with rare tokens replaced with <unk>'s
    public func replaceRareTokens(minimumCount threshold: Int) -> [String] {
        var frequency: [String: Int] = [:]
        self.forEach { frequency[$0] ?+= 1 }
        return self.map { frequency[$0]! > threshold ? $0 : unknown }
    }

}

extension Sequence where Iterator.Element == [String] {

    /// Replace rare tokens in a tokenized corpus (array of tokenized sentences)
    /// Complexity: O(n)
    ///
    /// - parameter minimumCount: Minimum count of a token in order not to be replaced with <unk>
    ///
    /// - returns: Corpus with rare tokens replaced with <unk>'s
    public func replaceRareTokens(minimumCount threshold: Int) -> [[String]] {
        if threshold <= 0 { return !!self }
        var frequency: [String: Int] = [:]
        // Collect frequency
        self.forEach { $0.forEach { frequency[$0] ?+= 1 } }
        // Replace
        return self.map { $0.map { frequency[$0]! > threshold ? $0 : unknown } }
    }
    
}

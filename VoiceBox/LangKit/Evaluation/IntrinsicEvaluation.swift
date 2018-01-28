//
//  IntrinsicEvaluation.swift
//  LangKit
//
//  Created by Richard Wei on 4/28/16.
//
//

import Foundation

extension NgramModel {

    /// Perplexity over a sentence
    /// 
    /// - parameter sentence: Tokenized sentence
    /// 
    /// - returns: Perplexity
    public func perplexity(sentence: [Token]) -> Float {
        let prob = sentenceLogProbability(sentence)
        return expf(-prob / Float(sentence.count))
    }

}
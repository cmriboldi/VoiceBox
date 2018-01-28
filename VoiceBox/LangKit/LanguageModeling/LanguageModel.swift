//
//  LanguageModel.swift
//  LangKit
//
//  Created by Richard Wei on 3/20/16.
//  Copyright © 2016 Richard Wei. All rights reserved.
//

public protocol LanguageModel {

    associatedtype Token

    associatedtype Item = [Token]

    associatedtype Sentence = [Token]

    /// Train the model with tokenized corpus
    ///
    /// - parameter corpus: Tokenized corpus
    mutating func train<C: Sequence where C.Iterator.Element == [Token]>(corpus: C)

    /// Probability of item
    ///
    /// - parameter item:     Item
    ///
    /// - returns: Probability
    func probability(_ item: Item) -> Float

    /// Markov conditional probability of item
    ///
    /// - parameter item:     Item
    ///
    /// - returns: Probability
    func markovProbability(_ item: Item) -> Float

    /// Log probability of tokenized sentence
    ///
    /// - parameter sentence: Tokenized sentence
    ///
    /// - returns: Log probability
    func sentenceLogProbability(_ sentence: Sentence) -> Float

}

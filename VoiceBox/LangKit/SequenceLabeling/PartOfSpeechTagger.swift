//
//  PartOfSpeechTagger.swift
//  LangKit
//
//  Created by Richard Wei on 4/14/16.
//
//

public final class PartOfSpeechTagger {

    let model: HiddenMarkovModel<String, String>

    ///	Initialize from tagged corpus
    public init<C: Sequence where C.Iterator.Element == [(String, String)]>
                (taggedCorpus corpus: C,
                 smoothingMode smoothing: SmoothingMode = .goodTuring) {
        model = HiddenMarkovModel(taggedCorpus: corpus, smoothingMode: smoothing, replacingItemsFewerThan: 0)
    }

}

extension PartOfSpeechTagger: Tagger {

    /// Tag a sequence
    ///
    /// - parameter sequence: Sequence of items [w0, w1, w2, ...]
    ///
    /// - returns: [(w0, t0), (w1, t1), (w2, t2), ...]
    public func tag(_ sequence: [String]) -> [(String, String)] {
        return model.tag(sequence)
    }

}
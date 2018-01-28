//
//  NaiveBayes.swift
//  LangKit
//
//  Created by Richard Wei on 3/22/16.
//
//

public struct NaiveBayes<Input, Label: Hashable> {

    public typealias ProbabilityFunction = Input -> Float

    private var probabilityFunctions: [Label: ProbabilityFunction] = [:]

    public var classes: [Label] {
        return !!probabilityFunctions.keys
    }

    public var flipped: Bool

    public init(probabilityFunctions probFuncs: [Label: ProbabilityFunction], flipped: Bool = false) {
        self.probabilityFunctions = probFuncs
        self.flipped = flipped
    }

    public init<T: LanguageModel where T.Sentence == Input>(languageModels: [Label: T], flipped: Bool = false) {
        var lms: [Label: ProbabilityFunction] = [:]
        languageModels.forEach { lms[$0] = $1.sentenceLogProbability }
        self.init(probabilityFunctions: lms, flipped: flipped)
    }

}

extension NaiveBayes {

    public mutating func add(classLabel: Label, probabilityFunction probFunc: ProbabilityFunction) {
        if !probabilityFunctions.keys.contains(classLabel)  {
            probabilityFunctions[classLabel] = probFunc
        }
    }

}

extension NaiveBayes : Classifier {

    public func classify(_ input: Input) -> Label? {
        return (flipped ? argmin : argmax)(Array(probabilityFunctions.keys)) {
            self.probabilityFunctions[$0]!(input)
        }
    }

}

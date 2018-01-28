//
//  Evaluator.swift
//  LangKit
//
//  Created by Richard Wei on 4/27/16.
//
//

public struct FScore {
    let beta: Float
    public let precision, recall: Float
    public var fScore: Float {
        let betaSqr = beta * beta
        return (1 + betaSqr) * (precision * recall / (betaSqr * precision + recall))
    }

    public init(precision: Float, recall: Float, betaFactor beta: Float = 1) {
        self.precision = precision
        self.recall = recall
        self.beta = beta
    }
}

public final class ClassifierEvaluator<C: Classifier> {

    let tests: [C.Input]
    let solutions: [C.Label]
    let classifier: C


    ///  Initialize from a classifier and solutions
    ///  
    ///  - parameter classifier: Classifier
    ///  - parameter tests:      Array of inputs
    ///  - parameter solutions:  Array of golden standard outputs
    public init<T: Sequence, U: Sequence where T.Iterator.Element == C.Input, U.Iterator.Element == C.Label>
                (classifier: C, tests: T, solutions: U) {
        self.tests = !!tests
        self.solutions = !!solutions
        self.classifier = classifier
    }

    ///  Compute the F-score for all classes
    ///
    ///  - parameter beta: Beta factor for F-score calculation (default: 1.0)
    ///
    ///  - returns: Dictionary of F-scores indexed by classes
    public func fScores(beta: Float = 1) -> [C.Label: FScore] {
        // Confusion matrix
        var matrix: [C.Label: [C.Label: Int]] = [:]
        classifier.classes.forEach { matrix[$0] = [:] }
        for (test, gold) in zip(tests, solutions) {
            classifier.classify(test) >>- { predicted in
                matrix[predicted]![gold] ?+= 1
            }
        }
        var scores: [C.Label: FScore] = [:]
        classifier.classes.forEach { label in
            let truePositive = matrix[label]![label] ?? 0
            let totalGold = matrix[label]!.values.reduce(0, combine: +)
            let totalPredicted = matrix.values.reduce(0) { $0 + ($1[label] ?? 0) }
            scores[label] = FScore(precision: Float(truePositive) / Float(totalPredicted),
                                      recall: Float(truePositive) / Float(totalGold),
                                  betaFactor: beta)
        }
        return scores
    }

}
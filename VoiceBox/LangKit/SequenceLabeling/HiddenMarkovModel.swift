//
//  HiddenMarkovModel.swift
//  LangKit
//
//  Created by Richard Wei on 3/20/16.
//  Copyright © 2016 Richard Wei. All rights reserved.
//

import Foundation

/// Transition conformance to Equatable
public func ==<T>(lhs: Transition<T>, rhs: Transition<T>) -> Bool {
    return lhs.state1 == rhs.state1 && lhs.state2 == rhs.state2
}

/// Emission conformance to Equatable
public func ==<T, U>(lhs: Emission<T, U>, rhs: Emission<T, U>) -> Bool {
    return lhs.state == rhs.state && lhs.item == rhs.item
}

/// Transition hash key
public struct Transition<T: Hashable> : Hashable {
    public let state1, state2: T
    public let hashValue: Int
    public init(_ state1: T, _ state2: T) {
        self.state1 = state1
        self.state2 = state2
        hashValue = 31 &* state1.hashValue &+ state2.hashValue
    }
}

/// Emission hash key
public struct Emission<T: Hashable, U: Hashable> : Hashable {
    public let state: T
    public let item: U
    public let hashValue: Int
    public init(_ state: T, _ item: U) {
        self.state = state
        self.item = item
        hashValue = 31 &* state.hashValue &+ item.hashValue
    }
}

/// Lazily cached hidden Markov model for sequence labeling
public final class HiddenMarkovModel<Item: Hashable, Label: Hashable> {

    public typealias TransitionType = Transition<Label>
    public typealias EmissionType = Emission<Label, Item>

    /// Fundamental components
    ///
    // Seen items
    public private(set) var items: Set<Item>
    // States
    public private(set) var states: Set<Label>
    // Probability tables
    private var    initial: [Label: Float]          = [:]
    private var transition: [TransitionType: Float] = [:]
    private var   emission: [EmissionType: Float]   = [:]

    /// Count training
    ///
    // Count tables
    private var    initialCountTable: [Label: Int]          = [:]
    private var transitionCountTable: [TransitionType: Int] = [:]
    private var   emissionCountTable: [EmissionType: Int]   = [:]
    // Total number of seen sequences
    private var sequenceCount: Int = 0
    // Total number of seen transitions
    private var transitionCount: Int = 0
    // Total number of seen emissions
    private var emissionCount: Int = 0
    // State count table
    private var stateCountTable: [Label: Int] = [:]

    /// Configuration
    ///
    // Smoothing mode
    private let smoothing: SmoothingMode
    // Rare item replacement threshold
    private let threshold: Int
    // Minimum probability limit
    private let minimumProbability: Float = 0.1e-44

    /// Smoothing specific
    ///
    // Unseen emission count table
    private var unseenEmissionCountTable: [Label: Int] = [:]
    // Good-Turing smoothing -- count frequency tables
    private var transitionCountFrequency: [Int: Int]!
    private var   emissionCountFrequency: [Int: Int]!


    /// Initialize from HMM counts
    ///
    /// - parameter initial:    Initial probability distribution
    /// - parameter transition: Transition probability distribution
    /// - parameter emission:   Emission probability distribution
    public init(initialCountTable initial: [Label: Int],
                transitionCountTable transition: [TransitionType: Int],
                emissionCountTable emission: [EmissionType: Int],
                seenSequenceCount sequenceCount: Int,
                smoothingMode smoothing: SmoothingMode = .none,
                replacingItemsFewerThan threshold: Int = 0) {
        self.initialCountTable = initial
        self.transitionCountTable = transition
        self.emissionCountTable = emission
        self.sequenceCount = sequenceCount
        self.threshold = threshold
        self.smoothing = smoothing
        self.items = emissionCountTable.keys.map{$0.item} |> Set.init
        self.states = transitionCountTable.keys.flatMap{[$0.state1, $0.state2]} |> Set.init
        updateUnseenEmissionCountTable()
        self.transitionCountTable.keys.forEach { self.stateCountTable[$0.state1] ?+= 1 }

        // Initialize smoothing data structures
        if case .goodTuring = smoothing {
            transitionCountFrequency = [:]
            emissionCountFrequency   = [:]
            transitionCountTable.values.forEach { transitionCountFrequency![$0] ?+= 1 }
            emissionCountTable.values.forEach   {   emissionCountFrequency![$0] ?+= 1 }
        }
    }

    /// Initialize from HMM probability tables
    ///
    /// - parameter initial:    Initial probability table
    /// - parameter transition: Transition probability table
    /// - parameter emission:   Emission probability table
    public init(initialProbability initial: [Label: Float],
                transitionProbability transition: [TransitionType: Float],
                emissionProbability emission: [EmissionType: Float]) {
        self.initial = initial
        self.transition = transition
        self.emission = emission
        self.threshold = 0
        self.smoothing = .none
        self.items = emission.keys.map{$0.item} |> Set.init
        self.states = transition.keys.flatMap{[$0.state1, $0.state2]} |> Set.init
    }

    /// Initialize from tagged corpus
    ///
    /// - parameter taggedCorpus: Tagged corpus
    public init<C : Sequence where C.Iterator.Element == [(Item, Label)]>
                (taggedCorpus corpus: C,
                 smoothingMode smoothing: SmoothingMode = .none,
                 replacingItemsFewerThan threshold: Int = 0) {
        self.threshold = threshold
        self.smoothing = smoothing
        self.items = []
        self.states = []
        if case .goodTuring = smoothing {
            transitionCountFrequency = [:]
            emissionCountFrequency   = [:]
        }
        train(labeledSequences: corpus)
    }

}

// MARK: - Probability functions. Cache *mutating*
extension HiddenMarkovModel {

    public func initialProbability(state: Label) -> Float {
        // Lookup cache
        if let prob = initial[state] {
            return prob
        }
        // Compute probability
        var prob: Float
        guard let count = initialCountTable[state] else {
            return minimumProbability
        }
        prob = Float(count) / Float(sequenceCount)
        // Write cache
        initial[state] = prob
        return prob
    }

    public func transitionProbability(from state1: Label, to state2: Label) -> Float {
        return transitionProbability(TransitionType(state1, state2))
    }

    private func transitionProbability(_ transition: TransitionType) -> Float {
        // Lookup cache
        if let prob = self.transition[transition] {
            return prob
        }
        // Compute probability
        var prob: Float
        let count = self.transitionCountTable[transition] ?? 0
        if count == 0 { return minimumProbability }
        let stateCount = stateCountTable[transition.state1]!
        switch smoothing {
        case .none:
            prob = Float(count) / Float(stateCount)
        case .laplace(let k):
            prob = (Float(count) + k) / (Float(stateCount) + k * Float(transitionCount))
        case .goodTuring:
            let numCount = transitionCountFrequency[count]!
            let numCountPlusOne = transitionCountFrequency[count + 1] ?? 1
            let smoothedCount = Float(count + 1) * (Float(numCountPlusOne) / Float(numCount))
            prob = smoothedCount / Float(stateCount)
        case .absoluteDiscounting:
            // Unsupported for now
            return minimumProbability
        case .linearInterpolation:
            // Currently nsupported
            return minimumProbability
        }
        // Write cache
        self.transition[transition] = prob
        return prob
    }

    public func emissionProbability(from state: Label, to item: Item) -> Float {
        return emissionProbability(EmissionType(state, item))
    }

    private func emissionProbability(_ emission: EmissionType) -> Float {
        // Lookup cache
        if let prob = self.emission[emission] {
            return prob
        }
        // Compute probability
        var prob: Float
        let count = self.emissionCountTable[emission] ?? self.unseenEmissionCountTable[emission.state] ?? 0
        if count == 0 { return minimumProbability }
        let stateCount = stateCountTable[emission.state]!
        switch smoothing {
        case .none:
            prob = Float(count) / Float(stateCount)
        case .laplace(let k):
            prob = (Float(count) + k) / (Float(stateCount) + k * Float(emissionCount))
        case .goodTuring:
            let numCount = emissionCountFrequency[count]!
            let numCountPlusOne = emissionCountFrequency[count + 1] ?? 1
            let smoothedCount = Float(count + 1) * (Float(numCountPlusOne) / Float(numCount))
            prob = smoothedCount / Float(stateCount)
        case .linearInterpolation:
            // TODO
            return minimumProbability
        case .absoluteDiscounting:
            // TODO
            return minimumProbability
        }
        // Write cache
        self.emission[emission] = prob
        return prob
    }

}

// MARK: - Preprocessing
extension HiddenMarkovModel {

    ///	Update unseen (<unk>) emission count table
    /// Called whenever counts are updated
    private func updateUnseenEmissionCountTable() {
        for (em, count) in emissionCountTable where count <= threshold {
            let state = em.state
            self.unseenEmissionCountTable[state] ?+= 1
            defer {
                // Remove from original count table
                emissionCountTable.removeValue(forKey: em)
            }
        }
    }

}

// MARK: - SequenceLabelingModel conformance
extension HiddenMarkovModel : SequenceLabelingModel {

    /// Train the model with tagged corpus
    /// Available for incremental training
    /// Complexity: O(n^2)
    /// 
    /// - parameter taggedCorpus: Tagged corpus
    public func train<C : Sequence where C.Iterator.Element == [(Item, Label)]>(labeledSequences corpus: C) {
        for sentence in corpus {
            // Add initial
            let (_, head) = sentence[0]
            initialCountTable[head] ?+= 1

            // Increment total sequence count
            sequenceCount += 1

            // Collect transitions and emissions in each sentence
            for (i, (token, label)) in sentence.enumerated() {
                // Add seen item
                items.insert(token)
                // Add state
                states.insert(label)

                // Increment state count
                stateCountTable[label] ?+= 1

                // Increment emission count
                let emissionKey = Emission(label, token)
                let emissionCount = 1 + (emissionCountTable[emissionKey] ?? 0)
                emissionCountTable[emissionKey] = emissionCount

                // Add transition (s_{i} -> s_{i+1})
                // if s_{i} is not the end of the sequence
                if i < sentence.count - 1 {
                    let (_, nextLabel) = sentence[i+1]
                    // Add transition
                    let transitionKey = Transition(label, nextLabel)
                    let transitionCount = 1 + (transitionCountTable[transitionKey] ?? 0)
                    transitionCountTable[transitionKey] = transitionCount

                    // Adjust transition count frequency for Good Turing smoothing
                    if case .goodTuring = smoothing {
                        transitionCountFrequency[transitionCount] ?+= 1
                        let prevTransCountFreq = transitionCountFrequency[transitionCount-1] ?? 0
                        if prevTransCountFreq > 0 {
                            transitionCountFrequency[transitionCount-1] = prevTransCountFreq
                        }
                    }
                }

                // Adjust emission count frequency for Good Turing smoothing
                if case .goodTuring = smoothing {
                    emissionCountFrequency[emissionCount] ?+= 1
                    let prevEmCountFreq = emissionCountFrequency[emissionCount-1] ?? 0
                    if prevEmCountFreq > 0 {
                        emissionCountFrequency[emissionCount-1] = prevEmCountFreq
                    }
                }
            }
        }
        updateUnseenEmissionCountTable()

        // Empty probability tables
        self.initial.removeAll(keepingCapacity: true)
        self.transition.removeAll(keepingCapacity: true)
        self.emission.removeAll(keepingCapacity: true)
    }

    /// Tag an observation sequence (sentence) using Viterbi algorithm
    /// Complexity: O(n * |S|^2)   where S = state space
    ///
    /// - parameter sequence: Sentence [w0, w1, w2, ...]
    ///
    /// - returns: Tagged sentence [(w0, t0), (w1, t1), (w2, t2), ...]
    public func tag(_ sequence: [Item]) -> [(Item, Label)] {
        let (_, labels) = viterbi(observation: sequence)
        return !!zip(sequence, labels)
    }

}

// MARK: - Algorithms
extension HiddenMarkovModel {
    /// Viterbi Algorithm - Find the most likely sequence of hidden states
    /// A nasty implementation directly ported from Python version (needs rewriting)
    /// Complexity: O(n * |S|^2)   where S = state space
    ///
    /// - parameter observation: Observation sequence
    ///
    /// - returns: Most likely label sequence along with probabolity
    public func viterbi(observation: [Item]) -> (probability: Float, label: [Label]) {
        if observation.isEmpty {
            return (0.0, [])
        }
        var trellis : [[Label: Float]] = [[:]]
        var path: [Label: [Label]] = [:]
        for y in states {
            trellis[0][y] = -logf(initialProbability(state: y)) - logf(emissionProbability(Emission(y, observation[0])))
            path[y] = [y]
        }
        for i in 1..<observation.count {
            trellis.append([:])
            var newPath: [Label: [Label]] = [:]
            for y in states {
                var bestArg: Label = states.first!
                var bestProb: Float = Float.infinity
                for y0 in states {
                    let prob = trellis[i-1][y0]! -
                                (transitionProbability(Transition(y0, y)) |> logf) -
                                (emissionProbability(Emission(y, observation[i])) |> logf)
                    if prob < bestProb {
                        bestArg = y0
                        bestProb = prob
                    }
                }
                trellis[i][y] = bestProb
                newPath[y] = path[bestArg]! + [y]
            }
            path = newPath
        }
        let n = observation.count - 1
        var bestArg: Label!, bestProb: Float = Float.infinity
        for y in states where trellis[n][y] < bestProb {
            bestProb = trellis[n][y]!
            bestArg = y
        }
        return (probability: bestProb, label: path[bestArg]!)
    }
}

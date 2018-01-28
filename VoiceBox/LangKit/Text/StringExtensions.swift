//
//  Tokenizedr.swift
//  LangKit
//
//  Created by Richard Wei on 3/20/16.
//  Copyright © 2016 Richard Wei. All rights reserved.
//

// MARK: - Tokenization
public extension String.CharacterView {

    public func tokenized() -> [SubSequence] {
        return split(separator: " ", omittingEmptySubsequences: true)
    }

    public func lineSplit() -> [SubSequence] {
        let delimiterSet: Set<Character> = ["\n", "\r"]
        return split(omittingEmptySubsequences: true, isSeparator: delimiterSet.contains)
    }

    public func tagSplit(delimiter: Character) -> (String, String) {
        let subseq = split(separator: delimiter)
        guard subseq.count >= 2 else {
            return (String(subseq.first), unknown)
        }
        return (String(subseq[0]), String(subseq[1]))
    }

}

// MARK: - Tokenization
public extension String {

    @inline(__always)
    public func tokenized() -> [String] {
        return characters.tokenized().map{String($0)}
    }


    @inline(__always)
    public func lineSplit() -> [String] {
        return characters.lineSplit().map{String($0)}
    }

    @inline(__always)
    public func letterized() -> [String] {
        return characters.map{String($0)}
    }

    @inline(__always)
    public func tagSplit() -> (String, String) {
        return characters.tagSplit(delimiter: "_")
    }

    @inline(__always)
    public func tagSplit(delimiter: Character) -> (String, String) {
        return characters.tagSplit(delimiter: delimiter)
    }

    @inline(__always)
    public func tagTokenized(delimiter: Character) -> [(String, String)] {
        return characters.tokenized().map{$0.tagSplit(delimiter: delimiter)}
    }

    // Parameterization
    @inline(__always)
    public func tagTokenized() -> [(String, String)] {
        return tagTokenized(delimiter: "_")
    }
}


// MARK: - Similarity
public extension String {

    ///	Calculate Levenshtein minimum edit distance
    ///
    ///	- parameter other:	Other string
    ///
    ///	- returns: Minimum edit distance
    public func levenshteinDistance(_ other: String) -> Int {
        if self.isEmpty { return other.characters.count }
        if other.isEmpty { return self.characters.count }
        let cost = self.characters.last! == other.characters.last! ? 0 : 1
        let selfButLast = String(self.characters.dropLast())
        let otherButLast = String(other.characters.dropLast())
        return min(1 + selfButLast.levenshteinDistance(other),
                   1 + levenshteinDistance(otherButLast),
                   cost + selfButLast.levenshteinDistance(otherButLast))
    }

}
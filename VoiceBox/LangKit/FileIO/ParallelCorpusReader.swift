//
//  ParallelCorpusReader.swift
//  LangKit
//
//  Created by Richard Wei on 4/20/16.
//
//

import Foundation

public final class ParallelCorpusReader {

    public typealias SentenceTuple = ([String], [String])

    private let fReader, eReader: TokenCorpusReader

    public init?(fromFFile fPath: String, fromEFile ePath: String,
                sentenceSeparator separator: String = "\n",
                encoding: NSStringEncoding = NSUTF8StringEncoding,
                tokenizingWith tokenize: String -> [String] = ^String.tokenized) {
        guard let f = TokenCorpusReader(fromFile: fPath,
                                        sentenceSeparator: separator,
                                        encoding: encoding,
                                        tokenizingWith: tokenize),
                  e = TokenCorpusReader(fromFile: ePath,
                                        sentenceSeparator: separator,
                                        encoding: encoding,
                                        tokenizingWith: tokenize) else { return nil }
        fReader = f
        eReader = e
    }

}

// MARK: - State
extension ParallelCorpusReader {

    public func rewind() {
        fReader.rewind()
        eReader.rewind()
    }

}

// MARK: - IteratorProtocol conformance
extension ParallelCorpusReader : IteratorProtocol {

    public typealias Element = SentenceTuple

    public func next() -> Element? {
        guard let fNext = fReader.next(), eNext = eReader.next() else {
            return nil
        }
        return (fNext, eNext)
    }

}

// MARK: - Sequence conformance
extension ParallelCorpusReader : Sequence {

    public typealias Iterator = ParallelCorpusReader

    public func makeIterator() -> Iterator {
        rewind()
        return self
    }

}
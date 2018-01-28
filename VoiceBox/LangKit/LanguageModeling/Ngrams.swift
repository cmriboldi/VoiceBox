/**
 * Ngram.swift
 *
 */

public extension Array {

    /// Generate ngrams
    ///
    /// - parameter n: n-value
    ///
    /// - returns: Ngram sequence
    public func ngrams(_ n: Int) -> Ngrams<Element> {
        return .init(self, n)
    }

}

/// Form of ngram split
///
/// - letter: Split to letters
/// - word:   Split to words
public enum NgramForm {
    case letter
    case word
}

// MARK: - Ngram generation from String
public extension String {

    public func ngrams(_ n: Int, form: NgramForm) -> Ngrams<String> {
        switch form {
        case .letter:
            return characters.map{String($0)}.ngrams(n)
        case .word:
            return self.tokenized().ngrams(n)
        }
    }

}

public struct Ngrams<T> : IteratorProtocol, Sequence {

    public typealias Element = [T]

    private let n: Int
    private var source: [T]

    public init(_ source: [T], _ n: Int) {
        self.n = n
        self.source = source
    }

    public func generate() -> Ngrams {
        return self
    }

    public mutating func next() -> Element? {
        guard source.count >= n else {
            return nil
        }
        let ngram = !!source.prefix(n)
        self.source.removeFirst()
        return ngram
    }

}

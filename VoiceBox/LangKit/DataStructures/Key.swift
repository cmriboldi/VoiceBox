//
//  Key.swift
//  LangKit
//
//  Created by Richard Wei on 4/13/16.
//
//

public func ==<Element>(lhs: ArrayKey<Element>, rhs: ArrayKey<Element>) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public struct ArrayKey<Element: Hashable> : Hashable, ArrayLiteralConvertible {

    private let elements: [Element]

    public let hashValue: Int

    public init(arrayLiteral elements: Element...) {
        self.elements = elements
        hashValue = elements.reduce(0) { acc, x in
            31 &* acc.hashValue &+ x.hashValue
        }
    }

    public subscript(index: Int) -> Element {
        return elements[index]
    }

}

//
//  Parameterization.swift
//  LangKit
//
//  Created by Richard Wei on 4/16/16.
//
//

import Foundation

/// Parameterized print function from print(...)
///
/// - parameter item: Single item
@inline(__always)
public func print<T>(_ item: T) {
    print(item)
}

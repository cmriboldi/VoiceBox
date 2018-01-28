//
//  Smoothing.swift
//  LangKit
//
//  Created by Richard Wei on 4/17/16.
//
//

import Foundation

/// Smoothing mode for various statistical models
///
/// - none:                No smoothing
/// - laplace:             Laplace (additive) smoothing with factor
/// - goodTuring:          Good Turing smoothing
/// - linearInterpolation: Linear interpolation
/// - absoluteDiscounting: Absolute discounting
public enum SmoothingMode : ExpressibleByNilLiteral {
    case none
    case laplace(Float)
    case goodTuring
    case linearInterpolation
    case absoluteDiscounting
    
    public init(nilLiteral: ()) {
        self = .none
    }
}

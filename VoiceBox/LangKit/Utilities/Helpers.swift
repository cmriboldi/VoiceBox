//
//  Helpers.swift
//  LangKit
//
//  Created by Richard Wei on 4/16/16.
//
//

///	Force generate
/// Equivalent to .map{$0}
prefix operator !! {}

/// Instance method invocation closure
prefix operator ^ {}

/// Increment optional variable while unwrapping with default value if nil
infix operator ?+= {
    associativity right
    precedence 90
    assignment
}

/// Increment optional variable while force-unwrapping
infix operator !+= {
    associativity right
    precedence 90
    assignment
}

/// Instance method invoker
///
/// - parameter f: Uninstantiated instance method (A -> () -> B)
///
/// - returns: Uninstantiated method with auto invocation (A -> B)
@inline(__always)
public prefix func ^<A, B>(f: A -> () -> B) -> A -> B {
    return {f($0)()}
}

/// Generate an array from a sequence
///
/// - parameter sequence: Sequence
///
/// - returns: Array
@inline(__always)
public prefix func !!<A, B: Sequence where B.Iterator.Element == A>
                      (sequence: B) -> [A] {
    return sequence.map{$0}
}

/// Increment while unwrapping with default value if nil
///
/// - returns: Incremented value
@inline(__always)
public func ?+=<T: Integer>(lhs: inout T?, rhs: T) {
    lhs = rhs + (lhs ?? 0)
}
@inline(__always)
public func ?+=(lhs: inout Float?, rhs: Float) {
    lhs = rhs + (lhs ?? 0.0)
}
@inline(__always)
public func ?+=(lhs: inout Double?, rhs: Double) {
    lhs = rhs + (lhs ?? 0.0)
}

/// Increment while force-unwrapping
///
/// - returns: Incremented value
@inline(__always)
public func !+=<T: Integer>(lhs: inout T?, rhs: T) {
    lhs = rhs + lhs!
}
@inline(__always)
public func !+=(lhs: inout Float?, rhs: Float) {
    lhs = rhs + lhs!
}
@inline(__always)
public func !+=(lhs: inout Double?, rhs: Double) {
    lhs = rhs + lhs!
}
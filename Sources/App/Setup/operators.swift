//
//  operators.swift
//  App
//
//  Created by Florian Fittschen on 09.03.19.
//

infix operator ?!: NilCoalescingPrecedence
public func ?!<A>(lhs: A?, rhs: Error) throws -> A {
    guard let value = lhs else {
        throw rhs
    }
    return value
}

//
//  File.swift
//
//
//  Created by Niall Ó Broin on 01/07/2020.
//

import Foundation
//import Numerics


public enum QLen: Int {
    case q27 = 26
    case q19 = 18
    case q7 = 6
}



///Use Real for testing, in reality always BinaryFloatingPoint
//struct QVec<T: Real> {
public struct QVec<T: BinaryFloatingPoint> {
    public var q: [T]

    public init(qLen: QLen) {
        self.q = Array(repeating: T.zero, count: qLen.rawValue)
    }

    public init(with initialVal: T, qLen: QLen) {
        
        self.q = Array(repeating: initialVal, count: qLen.rawValue)
    }

    public init(with q: [T]) {
        self.q = q
    }

}


public struct Force<T: BinaryFloatingPoint> {
    public var x: T
    public var y: T
    public var z: T

    public init(x: T, y: T, z: T) {
        self.x = x
        self.y = y
        self.z = z
    }
}


public struct Velocity<T: BinaryFloatingPoint> {
    public var x: T
    public var y: T
    public var z: T

    public init(x: T, y: T, z: T) {
        self.x = x
        self.y = y
        self.z = z
    }
}


//
//  File.swift
//
//
//  Created by Niall Ó Broin on 01/07/2020.
//

import Foundation
//import Numerics


///Represented by Real for testing, in reality always BinaryFloatingPoint
//struct LB<TQ: Real> {
public struct LB<TQ: BinaryFloatingPoint> {
    public var grid: [[[ Q<TQ> ]]]
    public var x: Int
    public var y: Int
    public var z: Int

    init(with initialQ: Q<TQ>, x: Int, y:Int, z:Int, qLen: QLen) {
        self.x = x
        self.y = y
        self.z = z

        grid = Array(repeating: Array(repeating: Array(repeating: initialQ, count: z), count: y), count: x)

        
        
        //        for i in 0..<x {
//            for j in 0..<y {
//                for k in 0..<z {
//
//                    let o = TQ(i * 10000  + j * 1000 + k * 100)
//
//                    var u = [TQ]()
//                    u.append(contentsOf: stride(from: 0, to: TQ(qLen.rawValue), by: 1))
//
//                    grid[i][j][k].q = u.map({o + $0})
//                }}}
    }
}




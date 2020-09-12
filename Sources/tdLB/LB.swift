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
    public var grid: [[[ QVec<TQ> ]]]
    public var x: Int
    public var y: Int
    public var z: Int
    public var qLen: QLen

    init(withQVec initial: QVec<TQ>, x: Int, y:Int, z:Int, qLen: QLen) {
        self.x = x
        self.y = y
        self.z = z
        self.qLen = qLen

        grid = Array(repeating: Array(repeating: Array(repeating: initial, count: z), count: y), count: x)
    }


    init(with initialVal: TQ, x: Int, y:Int, z:Int, qLen: QLen) {
        self.x = x
        self.y = y
        self.z = z
        self.qLen = qLen

        let q = QVec<TQ>(with: initialVal, qLen: qLen)
        
        grid = Array(repeating: Array(repeating: Array(repeating: q, count: z), count: y), count: x)
        
    }
    
    init(x: Int, y:Int, z:Int, qLen: QLen) {
        self.init(with: 0, x:x, y:y, z:z, qLen:qLen)
    }

    
    ///Sets up the LB Matrix with some dummy test data
    mutating func setPositionalDataForTesting(){
        
        for i in 0..<x {
            for j in 0..<y {
                for k in 0..<z {

                    let o = TQ(i * 10000  + j * 1000 + k * 100)

                    let q: [TQ] = (0..<qLen.rawValue).indices.map { o + TQ($0)/100.0 }

                    
//                    u.append(contentsOf: stride(from: 0, to: TQ(qLen.rawValue), by: 1))
//
//                    grid[i][j][k].q = u.map({o + $0})
        
                    grid[i][j][k].q = q
                
                }}}
    }
    

}




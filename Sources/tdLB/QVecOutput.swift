//
//  File.swift
//
//
//  Created by Niall Ó Broin on 11/09/2020.
//

import Foundation



extension ComputeUnit {

    public func writeSparseOrthoPlaneXY<tCoordType: BinaryInteger, QVecType: BinaryFloatingPoint>(to dir: URL, at cutAt: Int, qOutputLength: Int, tCoordType: tCoordType.Type, QVecType: QVecType.Type) {

        if type(of: tCoordType) == Int.self {
            fatalError("Do not write as Type 'Int' as it is platform dependant.")
        }

        var myData = Data()
        var numStructs = 0
        
        for i in 0..<x {
            for j in 0..<y {

                let k: Int = Int(cutAt)

                //https://stackoverflow.com/questions/38023838/round-trip-swift-number-types-to-from-data

                myData.append(withUnsafeBytes(of: tCoordType.init(i)) { Data($0) })
                myData.append(withUnsafeBytes(of: tCoordType.init(j)) { Data($0) })

                for l in 0..<qOutputLength {

                    myData.append(withUnsafeBytes(of: QVecType.init(self.Q[i][j][k].q[ l ])) { Data($0) })
                }

                numStructs += 1
            }}

//        binFile.cutAt = cutAt
//        binFile.qOutputLength = qOutputLength
//        binFile.tCoordType = tCoordType
//        binFile.QVecType = QVecType
        
        try! myData.write(to: dir)

        try! writeJson(to: dir)


    }

    func writeJson(to: URL) throws {
        
    }
    
    public func writeSparseVolume() {

    }

    public func writeDenseVolume() {

    }

}//end of LB Entension



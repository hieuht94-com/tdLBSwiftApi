//
//  File.swift
//  
//
//  Created by Niall Ó Broin on 11/09/2020.
//

import Foundation
import tdLB


extension ComputeUnit {

    public func writeSparse2DPlaneXY<tCoordType: BinaryInteger, QVecType: BinaryFloatingPoint>(to binFileURL: URL, at cutAt: Int, qOutputLength: Int, tCoordType: tCoordType.Type, QVecType: QVecType.Type) {

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

        try! myData.write(to: binFileURL)

        
        
        let d = QVecBinMeta(qDataType: String(describing: QVecType),
                         qOutputLength: qOutputLength,
                         binFileSizeInStructs: numStructs,
                         coordsType: String(describing: tCoordType),
                         gridX: x, gridY: y, gridZ: z,
                         hasColRowtCoords: true,
                         hasGridtCoords: false,
                         idi: 1, idj: 1, idk: 1,
                         name: "Written from mockLB in QVecTool Tests",
                         ngx: 1, ngy: 1, ngz: 1,
                         structName: "tDisk_colrow")

        try! d.write(to: URL(fileURLWithPath: binFileURL.path + ".json"))

    }

    public func writeSparseVolume() {

    }

    public func writeDenseVolume() {

    }

}//end of LB Entension



//  QVecDims.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation
//import Logging
//let logger = Logger(label: "com.turbulentDynamics.QVecPostProcess.loadBuffer")




///QVec or QVectors
///The LB method does calculations on a Q Vector of varying length.  An implementation may contain extra information, bools or ints to store information on the type of that Cell.  A Cell and QVector are synomous.
///This class should handle all disk operations of the QVectors.  These can be stored in various formats, sparse with co-ordinate information or dense without coordinate information.  The QVectors can also be of various Float length, 16, 32 or 64, and for testing Integers.  Currently all co-ordinate information is Int32, though this could also be shortened in furture releases.
///


///https://github.com/apple/swift/blob/master/docs/ABI/TypeLayout.rst




public enum tDiskAlignment: String {
    case colrowQ3 = "tDisk_colrow_Q3_V4"
    case colrowQ4 = "tDisk_colrow_Q4_V4"
    case gridColrowQ3 = "tDisk_grid_colrow_Q3_V4"
    case gridColrowQ4 = "tDisk_grid_colrow_Q4_V4"
}




//activityIndicator.startAnimating()
//DispatchQueue.global(qos: .userInitiated).async {
//    do {
//        try Disk.save(largeData, to: .documents, as: "Movies/spiderman.mp4")
//    } catch {
//        // ...
//    }
//    DispatchQueue.main.async {
//        activityIndicator.stopAnimating()
//        // ...
//    }
//}






public struct tDiskBytesIndexNum {

    let colRowBytes = 2
    let gridBytes = 2
    let qBytes = 4

    var colRowNum: Int = 0
    var gridNum: Int = 0
    var qNum: Int = 0

    var colRowIndex: Int = 0
    var gridIndex: Int = 0
    var qIndex: Int = 0

    var structTotalBytes: Int



    init(structName: String) {


        switch structName {
            case "tDisk_colrow_Q3_V4":
                colRowNum = 2
                qNum = 3
                qIndex = colRowNum * colRowBytes

            case "tDisk_colrow_Q4_V4":
                colRowNum = 2
                qNum = 4
                qIndex = colRowNum * colRowBytes

            case "tDisk_grid_colrow_Q3_V4":
                colRowNum = 2
                gridNum = 3
                qNum = 3
                gridIndex = colRowNum * colRowBytes
                qIndex = gridIndex + gridNum * gridBytes

            case "tDisk_grid_colrow_Q4_V4":
                colRowNum = 2
                gridNum = 3
                qNum = 4
                gridIndex = colRowNum * colRowBytes
                qIndex = gridIndex + gridNum * gridBytes

            default:
                print("Hello")

        }

        structTotalBytes = qIndex + qNum * qBytes

    }

}

public struct tDisk<T:BinaryInteger, TQ:BinaryFloatingPoint> {
    var col: Int = -1
    var row: Int = -1
    var i: Int = -1
    var j: Int = -1
    var k: Int = -1
    var q = [TQ]()

    func calcPartialVelocity() -> Velocity<TQ> {
        //Needs to include forcing data here also, however there is much less forcing
        //data, so it might be faster to finish the calc with sparse forcing data later
        //v.ux = (q[1] + 0.5 * forcing.x) / q[0]

        var v = Velocity<TQ>()
        v.rho = q[0]

        v.ux = q[1] / v.rho
        v.uy = q[2] / v.rho
        v.uz = q[3] / v.rho
        return v
    }

}







//public class QVecIO {

public class diskSparseBuffer<T:BinaryInteger, TQ:BinaryFloatingPoint>  {
    //Useful references
    //https://www.raywenderlich.com/780-unsafe-swift-using-pointers-and-interacting-with-c
    //https://academy.realm.io/posts/nate-cook-tryswift-tokyo-unsafe-swift-and-pointer-types/
    //https://stackoverflow.com/questions/38983277/how-to-get-bytes-out-of-an-unsafemutablerawpointer

    let binURL: URL
    let data: Data

    let jsonBinURL: URL
    let dim: QVecDim
    let bytes: tDiskBytesIndexNum

    init(binURL: URL) throws {

        self.binURL = binURL

        let url:URL = binURL.deletingLastPathComponent()
        self.jsonBinURL = url.appendingPathComponent(binURL.lastPathComponent + ".json")


        self.dim = try QVecDim(jsonBinURL)
        self.bytes = tDiskBytesIndexNum(structName: dim.structName)

        self.data = try Data(contentsOf: binURL)
    }


    //    fileprivate func getItem(_ ptr: UnsafeRawBufferPointer, _ i: Int,
    //                             _ bytes: tDiskBytesIndexNum, _ hasColRowCoords: Bool, _ hasGridCoords: Bool) -> tDisk {
    //
    //        var item = tDisk()
    //
    //        if hasColRowCoords {
    //            item.col = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex, as: T.self))
    //            item.row = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex + bytes.colRowBytes, as: T.self))
    //        }
    //
    //        if hasGridCoords {
    //            item.i = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
    //            item.j = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
    //            item.k = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
    //
    //        }
    //
    //        for q in 0..<bytes.qNum {
    //            item.q.append(ptr.load(fromByteOffset: i + bytes.qIndex + (q * bytes.qBytes), as: TQ.self))
    //        }
    //        return item
    //    }
    //
    //
    //    func getSparseFromDiskDEBUG() throws -> [tDisk] {
    //
    //        var items = [tDisk]()
    //
    //        data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
    //            for i in stride(from: 0, to: dim.binFileSizeInStructs * bytes.structTotalBytes, by: bytes.structTotalBytes) {
    //
    //                let item = getItem(ptr, i, bytes, dim.hasColRowCoords, dim.hasGridCoords)
    //                items.append(item)
    //
    //            }
    //        }
    //        return items
    //    }



    func getSparseFromDisk() throws -> [tDisk<T, TQ>] {

        var items = [tDisk<T, TQ>]()

        data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
            for i in stride(from: 0, to: dim.binFileSizeInStructs * bytes.structTotalBytes, by: bytes.structTotalBytes) {

                var item = tDisk<T, TQ>()

                if dim.hasColRowCoords {
                    item.col = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex, as: T.self))
                    item.row = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex + bytes.colRowBytes, as: T.self))
                }

                if dim.hasGridCoords {
                    item.i = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
                    item.j = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
                    item.k = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
                }

                for q in 0..<bytes.qNum {
                    item.q.append(ptr.load(fromByteOffset: i + bytes.qIndex + (q * bytes.qBytes), as: TQ.self))
                }
                items.append(item)
            }
        }
        return items
    }





    func getPlaneFromDisk(plane: inout [[[TQ]]]) {

        data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
            for i in stride(from: 0, to: dim.binFileSizeInStructs * bytes.structTotalBytes, by: bytes.structTotalBytes) {

                var col = 0
                var row = 0

                if dim.hasColRowCoords {
                    col = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex, as: T.self))
                    row = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex + bytes.colRowBytes, as: T.self))
                }

                if dim.hasGridCoords {
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
                }

                for q in 0..<bytes.qNum {

                    let s = ptr.load(fromByteOffset: i + bytes.qIndex + (q * bytes.qBytes), as: TQ.self)

                    plane[col][row][q] = s
                }
            }
        }
    }


    //    func readPartialFileIntoLargerVelocity3DMatrix(velocity: inout [[[Velocity]]]) {
    //    func readPartialFileIntoLargerVelocity2DMatrix(velocity: inout [[Velocity]]) {
    func getVelocityFromDisk(addIntoPlane: inout OrthoVelocity2DPlane<TQ>) {

        data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
            for i in stride(from: 0, to: dim.binFileSizeInStructs * bytes.structTotalBytes, by: bytes.structTotalBytes) {

                var col = 0
                var row = 0

                if dim.hasColRowCoords {
                    col = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex, as: T.self))
                    row = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex + bytes.colRowBytes, as: T.self))
                }

                if dim.hasGridCoords {
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
                }


                //                print(col, row)

                addIntoPlane[col, row].rho = ptr.load(fromByteOffset: i + bytes.qIndex + (0 * bytes.qBytes), as: TQ.self)
                addIntoPlane[col, row].ux = ptr.load(fromByteOffset: i + bytes.qIndex + (1 * bytes.qBytes), as: TQ.self)
                addIntoPlane[col, row].uy = ptr.load(fromByteOffset: i + bytes.qIndex + (2 * bytes.qBytes), as: TQ.self)
                addIntoPlane[col, row].uz = ptr.load(fromByteOffset: i + bytes.qIndex + (3 * bytes.qBytes), as: TQ.self)

                //                print(row, col, addIntoPlane[col,row].rho, addIntoPlane[col,row].ux, addIntoPlane[col,row].uy, addIntoPlane[col,row].uz)


                //Skip the rest of the q matrix
                for q in 4..<bytes.qNum {
                    let _ = ptr.load(fromByteOffset: i + bytes.qIndex + (q * bytes.qBytes), as: TQ.self)
                }


            }
        }
    }


    func addForcingToPartialVelocity(velocity: inout [[Velocity<TQ>]]) {

        data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
            for i in stride(from: 0, to: dim.binFileSizeInStructs * bytes.structTotalBytes, by: bytes.structTotalBytes) {

                var col = 0
                var row = 0

                if dim.hasColRowCoords {
                    col = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex, as: T.self))
                    row = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex + bytes.colRowBytes, as: T.self))
                }

                if dim.hasGridCoords {
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: T.self))
                }


                let fx = ptr.load(fromByteOffset: i + bytes.qIndex + (0 * bytes.qBytes), as: TQ.self)
                let fy = ptr.load(fromByteOffset: i + bytes.qIndex + (1 * bytes.qBytes), as: TQ.self)
                let fz = ptr.load(fromByteOffset: i + bytes.qIndex + (2 * bytes.qBytes), as: TQ.self)

                for q in 3..<bytes.qNum {
                    let _ = ptr.load(fromByteOffset: i + bytes.qIndex + (q * bytes.qBytes), as: TQ.self)
                }


                //v.ux = (q[1] + 0.5 * forcing.x) / q[0]
                velocity[col][row].ux += fx / velocity[col][row].rho
                velocity[col][row].uy += fy / velocity[col][row].rho
                velocity[col][row].uz += fz / velocity[col][row].rho

            }
        }
    }



}

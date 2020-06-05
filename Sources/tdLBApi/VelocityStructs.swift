//  VelocityStructs.swift
//  tdLBApi
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation




public struct Velocity<tV: BinaryFloatingPoint> {
    //    var v = simd_float4(rho, ux, uy, uz)

    public var rho: tV
    public var ux: tV
    public var uy: tV
    public var uz: tV

    public init(){
        rho = tV.zero
        ux = tV.zero
        uy = tV.zero
        uz = tV.zero
    }

    public init(rho: tV, ux: tV, uy: tV, uz: tV){
        self.rho = rho
        self.ux = ux
        self.uy = uy
        self.uz = uz
    }
}




public struct OrthoVelocity2DPlane<tV: BinaryFloatingPoint> {

    var p: [[Velocity<tV>]]

    public init(cols:Int, rows: Int){
        self.p = Array(repeating: Array(repeating: Velocity(), count: cols), count: rows)
    }

    public var cols: Int {
        return p[0].count
    }

    public var rows: Int {
        return p.count
    }


    public subscript(c: Int, r: Int) -> Velocity<tV> {
        get {
            return p[c][r]
        }
        set(newValue) {
            p[c][r] = newValue
        }
    }





    private func formatWriteFileName(writeTo dir: URL, withSuffix: String) -> URL {

        let fileName: String = dir.lastPathComponent + withSuffix
        var modURL: URL = dir.deletingLastPathComponent()
        modURL.appendPathComponent(fileName)
        return modURL
    }


    public func writeVelocity(to fileName: URL, withBorder border: Int = 1){

        let height = cols - border * 2
        let width = rows - border * 2

        var writeBufferRHO = Array(repeating: tV.zero, count: height * width)
        var writeBufferUX = Array(repeating: tV.zero, count: height * width)
        var writeBufferUY = Array(repeating: tV.zero, count: height * width)
        var writeBufferUZ = Array(repeating: tV.zero, count: height * width)

        for col in border..<cols - border {
            for row in border..<rows - border {

                writeBufferRHO[(col - border) * height + (row - border) ] = p[col][row].rho
                writeBufferUX[ (col - border) * height + (row - border) ] = p[col][row].ux
                writeBufferUY[ (col - border) * height + (row - border) ] = p[col][row].uy
                writeBufferUZ[ (col - border) * height + (row - border) ] = p[col][row].uz

            }
        }


        // TODO: Eventually need to pass, height and width to file, or json or something.  Maybe use PPjson?


        var wData = Data(bytes: &writeBufferRHO, count: writeBufferRHO.count * MemoryLayout<tV>.stride)
        var url = formatWriteFileName(writeTo: fileName, withSuffix: ".rho.bin")
        try! wData.write(to: url)



        wData = Data(bytes: &writeBufferUX, count: writeBufferUX.count * MemoryLayout<tV>.stride)
        url = formatWriteFileName(writeTo: fileName, withSuffix: ".ux.bin")
        try! wData.write(to: url)

        wData = Data(bytes: &writeBufferUY, count: writeBufferUY.count * MemoryLayout<tV>.stride)
        url = formatWriteFileName(writeTo: fileName, withSuffix: ".uy.bin")
        try! wData.write(to: url)

        wData = Data(bytes: &writeBufferUZ, count: writeBufferUZ.count * MemoryLayout<tV>.stride)
        url = formatWriteFileName(writeTo: fileName, withSuffix: ".uz.bin")
        try! wData.write(to: url)


        //        print(url)



    }

}



public struct Velocity3DGrid<tV: BinaryFloatingPoint> {

    var g: [[[Velocity<tV>]]]

    public init(x: Int, y: Int, z: Int){
        self.g = Array(repeating: Array(repeating: Array(repeating: Velocity(), count: z + 2), count: y + 2), count: x + 2)
    }

    public subscript(i: Int, j: Int, k: Int) -> Velocity<tV> {
        get {
            return g[i][j][k]
        }
        set(newValue) {
            g[i][j][k] = newValue
        }
    }


}




//
//  tdGeometryRushtonTurbineLib.swift
//
//
//  Created by Niall Ó Broin on 26/03/2020.
//
import tdLB

public protocol Geometry {

    var gridX: Int {get}
    var gridY: Int {get}
    var gridZ: Int {get}

    var startingStep: Int {get}

    var geomFixed: [Pos3d] {get set}
    var geomRotating: [Pos3d] {get set}
    var geomTranslating: [Pos3d] {get set}

    init(fileName: String, outputJson: String) throws

    mutating func generateFixedGeometry()
    
    mutating func generateRotatingGeometry(atθ: Radian)
    
    mutating func generateTranslatingGeometry()
    
    mutating func updateGeometry(forStep step: Int)


    func getRotatingPointCloud() -> [PointCloudVertex]
    func getFixedPointCloud() -> [PointCloudVertex]

}

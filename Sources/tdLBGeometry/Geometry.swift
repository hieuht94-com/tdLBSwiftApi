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

    var geomFixed: [FixedGeomPoints] {get set}
    var geomRotating: [RotatingGeomPoints] {get set}
//    var geomMoving: [MovingGeomPoints] {get set}

    init(fileName: String, outputJson: String) throws

    mutating func generateFixedGeometry()
    
    mutating func generateRotatingGeometry(atθ: Radian)
    
//    mutating func generateMovingGeometry()

    
    mutating func updateGeometry(forStep step: Int)


    func getRotatingPointCloud() -> [PointCloudVertex]
    func getFixedPointCloud() -> [PointCloudVertex]

}

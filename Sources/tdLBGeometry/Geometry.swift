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
    
    mutating func generateRotatingNonUpdatingGeometry()

    
    mutating func generateRotatingGeometry(atθ: Radian)
    
    mutating func updateRotatingGeometry(atθ: Radian)
    
    
    mutating func generateTranslatingGeometry()
    
    mutating func updateTranslatingGeometry(forStep step: Int)

    
    
    
    
    func returnFixedGeometry() -> [Pos3d]

    func returnRotatingNonUpdatingGeometry() -> [Pos3d]

    func returnRotatingGeometry() -> [Pos3d]

    func returnTranslatingGeometry() -> [Pos3d]
    
    
}

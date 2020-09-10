//
//  apiGeometry.swift
//
//
//  Created by Niall Ó Broin on 24/03/2020.
//

import Foundation


public typealias Radian = Float
public typealias Degree = Float


public typealias FixedGeomPoints = RotatingGeomPoints
public typealias MovingGeomPoints = RotatingGeomPoints


public struct RotatingGeomPoints {

    public var r_polar: Radian = 0
    public var t_polar: Radian = 0

    public var iCartFP: Float = 0
    public var jCartFP: Float = 0
    public var kCartFP: Float = 0

    public var iCart: Int = 0
    public var jCart: Int = 0
    public var kCart: Int = 0

    public var iCartFraction: Radian {return iCartFP.truncatingRemainder(dividingBy: 1)}
    public var jCartFraction: Radian {return jCartFP.truncatingRemainder(dividingBy: 1)}
    public var kCartFraction: Radian {return kCartFP.truncatingRemainder(dividingBy: 1)}


    public var uDelta: Radian = 0
    public var vDelta: Radian = 0
    public var wDelta: Radian = 0


    public init(r_polar: Radian, t_polar: Radian,
         iCartFP: Radian, jCartFP:Radian, kCartFP:Radian,
         uDelta: Radian, vDelta:Radian, wDelta:Radian
    ){
        self.r_polar = r_polar
        self.t_polar = t_polar

        self.iCartFP = iCartFP
        self.jCartFP = jCartFP
        self.kCartFP = kCartFP

        self.uDelta = uDelta
        self.vDelta = vDelta
        self.wDelta = wDelta


        self.iCart = Int(ceil(iCartFP))
        self.jCart = Int(ceil(jCartFP))
        self.kCart = Int(ceil(kCartFP))

//        print(self.iCart, self.jCart, self.kCart)

    }


    public init(iCartFP: Float, jCartFP: Float, kCartFP: Float){
        self.iCartFP = iCartFP
        self.jCartFP = jCartFP
        self.kCartFP = kCartFP

        self.iCart = Int(ceil(iCartFP))
        self.jCart = Int(ceil(jCartFP))
        self.kCart = Int(ceil(kCartFP))

    }

    public init(iCart: Int, jCart: Int, kCart: Int){
        self.iCart = iCart
        self.jCart = jCart
        self.kCart = kCart
    }


}//end of struct




//
//  apiGeometry.swift
//
//
//  Created by Niall Ó Broin on 24/03/2020.
//

import Foundation
import tdLB



public struct PosPolar<T: BinaryInteger, TQ: BinaryFloatingPoint>
{
//    public var rPolar: Radian = 0
//    public var tPolar: Radian = 0
//
//    public var iFP: Float = 0
//    public var jFP: Float = 0
//    public var kFP: Float = 0

    public var i:T = 0;
    public var j:T = 0;
    public var k:T = 0;
    
    public var iCartFraction:TQ = 0.0;
    public var jCartFraction:TQ = 0.0;
    public var kCartFraction:TQ = 0.0;
    
    public var uDelta: TQ = 0.0;
    public var vDelta: TQ = 0.0;
    public var wDelta: TQ = 0.0;
    
    
    //Either 0 surface, or 1 solid (the cells between the surface)
    public var is_solid: Bool = false



    
    init(iFP:TQ, j:T, kFP:TQ){
        
        //CART ALWAYS goes to +ve position.
        //TOFIX
        //coord 3.25 returns 4, -1.25
        //coord 3.75 returns 4, -0.75
        
        //coord -3.25 returns -3, -0.75
        //coord -3.75 returns -3, -1.25
//        *integerPart = T(round(coordinate + 0.5));
//        *fractionPart = (TQ)(coordinate - (T)(*integerPart) - 0.5);
        
    
        self.i = T(round(iFP + 0.5))
        self.j = j
        self.k = T(round(kFP + 0.5))

        
        self.iCartFraction = iFP - (TQ(self.i) - 0.5)
        self.jCartFraction = 0.0
        self.kCartFraction = kFP - (TQ(self.k) - 0.5)

//        iCartFraction.truncatingRemainder(dividingBy: 1)
    }
    
    
    
    public init(iFP: TQ, jFP:TQ, kFP:TQ, uDelta: TQ, vDelta:TQ, wDelta:TQ){
        
        self.i = T(round(iFP + 0.5))
        self.j = T(round(jFP + 0.5))
        self.k = T(round(kFP + 0.5))
        
        self.iCartFraction = iFP - (TQ(self.i) - 0.5)
        self.jCartFraction = jFP - (TQ(self.j) - 0.5)
        self.kCartFraction = kFP - (TQ(self.k) - 0.5)
        
        self.uDelta = uDelta
        self.vDelta = vDelta
        self.wDelta = wDelta
   
    }
    
    
    public init(i: T, j: T, k: T){
        self.i = i
        self.j = j
        self.k = k
    }

    public func getPos3d() -> Pos3d{
        
        let u = Pos3d(i:Int(self.i), j:Int(self.j), k:Int(self.k))
        
        return u
    }
    
}//end of struct




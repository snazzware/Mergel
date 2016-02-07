//
//  HCPosition.swift
//  HexMatch
//
//  Created by Josh McKee on 2/5/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

class HCPosition : NSObject {
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
        
        super.init()
    }
    
    var north:HCPosition {
        get {
            return HCPosition(self.x,self.y+1)
        }
    }
    
    var northEast:HCPosition {
        get {
            if (self.x % 2 == 0) { // even
                return HCPosition(self.x+1,self.y+1)
            } else {
                return HCPosition(self.x+1,self.y)
            }
        }
    }
    
    var northWest:HCPosition {
        get {
            if (self.x % 2 == 0) { // even
                return HCPosition(self.x-1,self.y+1)
            } else {
                return HCPosition(self.x-1,self.y)
            }
        }
    }
    
    var south:HCPosition {
        get {
            return HCPosition(self.x,self.y-1)
        }
    }
    
    var southEast:HCPosition {
        get {
            if (self.x % 2 == 0) { // even
                return HCPosition(self.x+1,self.y)
            } else {
                return HCPosition(self.x+1,self.y-1)
            }
        }
    }
    
    var southWest:HCPosition {
        get {
            if (self.x % 2 == 0) { // even
                return HCPosition(self.x-1,self.y)
            } else {
                return HCPosition(self.x-1,self.y-1)
            }
        }
    }
    
    override var description: String {
        return "\(self.x),\(self.y)"
    }
}
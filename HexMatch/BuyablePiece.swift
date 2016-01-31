//
//  BuyablePiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/31/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

class BuyablePiece: NSObject, NSCoding  {

    var basePrice: Int = 0
    var currentPrice: Int = 0
    var value: Int = 0
    
    override init () {
        super.init()
    }
    
    override var description: String {
        return "Buyable Piece"
    }
    
    func resetPrice() {
        self.currentPrice = self.basePrice
    }
    
    func wasPurchased() {
        self.currentPrice = Int(Double(self.currentPrice) * 1.5)
    }
    
    func createPiece() -> HexPiece {
        let hexPiece = HexPiece()
        
        hexPiece.value = self.value
        
        return hexPiece
    }
    
    required init(coder decoder: NSCoder) {
        super.init()
    
        self.basePrice = (decoder.decodeObjectForKey("basePrice") as? Int)!
        self.currentPrice = (decoder.decodeObjectForKey("currentPrice") as? Int)!
        self.value = (decoder.decodeObjectForKey("value") as? Int)!
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.basePrice, forKey: "basePrice")
        coder.encodeObject(self.currentPrice, forKey: "currentPrice")
        coder.encodeObject(self.value, forKey: "value")
    }
    
}
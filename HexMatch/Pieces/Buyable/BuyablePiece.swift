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
    
        self.basePrice = decoder.decodeInteger(forKey: "basePrice")
        self.currentPrice = decoder.decodeInteger(forKey: "currentPrice")
        self.value = decoder.decodeInteger(forKey: "value")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.basePrice, forKey: "basePrice")
        coder.encode(self.currentPrice, forKey: "currentPrice")
        coder.encode(self.value, forKey: "value")
    }
    
}

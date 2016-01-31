//
//  WildcardBuyablePiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/31/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

class WildcardBuyablePiece: BuyablePiece {
 
    override init() {
        super.init()
        
        self.basePrice = 10000
        self.currentPrice = 10000
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override func createPiece() -> HexPiece {
        let hexPiece = WildcardHexPiece()
        
        hexPiece.value = self.value
        
        return hexPiece
    }

}
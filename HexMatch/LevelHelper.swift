//
//  LevelHelper.swift
//  HexMatch
//
//  Created by Josh McKee on 1/14/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

class LevelHelper: NSObject {
    // singleton
    static let instance = LevelHelper()
    
    // Distribution of random piece values. Piece value is index in array, array member value is the pct chance the index will be selected.
    let distribution = [50, 30, 20]
    
    // Chance to generate a wildcard piece (matches any value)
    let wildcardPercentage = 3
    
    // Chance to generate a mobile piece (moves around board until trapped)
    let mobilePercentage = 15

    /**
        Initializes a HexMap with a randomized starting layout

        - Parameters:
            - hexMap: Instance of HexMap to initialize
    */
    func initLevel(hexMap: HexMap) {
        var targetCell: HexCell? = nil
        
        // Clear the hexMap
        hexMap.clear()
        
        // Void out some cells
        for _ in 0...5 {
            // Find an empty, valid targe cell
            while (targetCell == nil || (targetCell != nil && targetCell!.isVoid)) {
                // pick a random coordinate
                let x = Int(arc4random_uniform(UInt32(hexMap.width)))
                let y = Int(arc4random_uniform(UInt32(hexMap.height)))
                
                // Get the cell
                targetCell = hexMap.cell(x,y)
            }
            
            targetCell!.isVoid = true
        }
        
        // Place some initial pieces
        for _ in 0...10 {
            // Find an empty, valid targe cell
            while (targetCell == nil || (targetCell != nil && targetCell!.hexPiece != nil) || (targetCell != nil && targetCell!.isVoid)) {
                // pick a random coordinate
                let x = Int(arc4random_uniform(UInt32(hexMap.width)))
                let y = Int(arc4random_uniform(UInt32(hexMap.height)))
                
                // Get the cell
                targetCell = hexMap.cell(x,y)
            }
            
            // Load a random non-wildcard piece in to the cell
            while (targetCell!.hexPiece == nil || targetCell!.hexPiece is WildcardHexPiece) {
                targetCell!.hexPiece = self.getRandomPiece()
            }
        }
    }
    
    /**
        Generates an instance of HexPiece with a random value, based on the set self.distribution.

        - Returns: Instance of HexPiece
    */
    func getRandomPiece() -> HexPiece {
        // Create a new hexPiece
        var hexPiece: HexPiece?
        
        let specialRoll = Int(arc4random_uniform(100))

        if (specialRoll<self.wildcardPercentage) { // Generate wildcard
            hexPiece = WildcardHexPiece()
        } else {
            if (specialRoll<self.mobilePercentage) { // Generate mobile
                hexPiece = MobileHexPiece()
            } else {
                hexPiece = HexPiece()
            }
        
            // Assign a random value
            let randomValue = Int(arc4random_uniform(100))
            
            // Start our distribution accumulator off with the first value in the set
            var distributionIndex = 0
            var distributionCurrentValue = self.distribution[distributionIndex]
            var distributionAccumulatedValue = distributionCurrentValue
            
            // Iterate over our distribution set, until our accumulated value exceeds the random value that was selected.
            while (distributionIndex < self.distribution.count-1 && distributionAccumulatedValue < randomValue) {
                distributionCurrentValue = self.distribution[++distributionIndex]
                distributionAccumulatedValue += distributionCurrentValue
            }
            
            // Use the index of whatever value our loop ended at as the value of the new piece
            hexPiece!.value = distributionIndex
        }
        
        return hexPiece!
    }

}
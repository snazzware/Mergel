//
//  LevelHelper.swift
//  HexMatch
//
//  Created by Josh McKee on 1/14/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

enum LevelHelperMode : Int {
    case Welcome = 1
    case Hexagon = 2
    case Pit = 3
    case Moat = 4
}

class LevelHelper: NSObject {
    // singleton
    static let instance = LevelHelper()
    
    var mode: LevelHelperMode = .Welcome    
    
    // Distribution of random piece values. Piece value is index in array, array member value is the pct chance the index will be selected.
    let distribution = [50, 30, 18, 2]
    
    // Chance to generate a wildcard piece (matches any value)
    let wildcardPercentage = 5
    
    // Chance to generate a mobile piece (moves around board until trapped)
    let mobilePercentage = 10
    
    // Chance to generate an enemy piece (moves around board until trapped)
    let enemyPercentage = 20
    
    func getLevelHelperModeCaption(mode: LevelHelperMode) -> String {
        var caption = "Error"
        
        switch mode {
            case .Welcome:
                caption = "Welcome"
            break
            case .Hexagon:
                caption = "Big Hexagon"
            break
            case .Pit:
                caption = "The Pit"
            break
            case .Moat:
                caption = "The Moat"
            break
        }
        
        return caption
    }

    /**
        Initializes a HexMap with a randomized starting layout

        - Parameters:
            - hexMap: Instance of HexMap to initialize
    */
    func initLevel(hexMap: HexMap) {
        var targetCell: HexCell? = nil
        
        // Clear the hexMap
        hexMap.clear()
        
        switch mode {
            case .Welcome:
                // Create radius 2 hexagon
                let voidCells = Set(hexMap.getAllCells()).subtract(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 2)))
                
                for voidCell in voidCells {
                    voidCell.isVoid = true
                }
            break
            case .Hexagon:
                // Create radius 3 hexagon
                let voidCells = Set(hexMap.getAllCells()).subtract(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 3)))
                
                for voidCell in voidCells {
                    voidCell.isVoid = true
                }
            break
            case .Pit:
                // Void out center of hex map
                let voidCells = hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 1)
                
                for voidCell in voidCells {
                    voidCell.isVoid = true
                }
            break
            case .Moat:
                // Void out moat in center of hex map
                let voidCells = Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 2)).subtract(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 1)))
                
                for voidCell in voidCells {
                    voidCell.isVoid = true
                }
                
                // add back left and right bridges
                hexMap.cell(1,3)!.isVoid = false
                hexMap.cell(5,3)!.isVoid = false
            break
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
            } else if (specialRoll<self.enemyPercentage) { // Generate mobile
                hexPiece = EnemyHexPiece()
            } else {
                hexPiece = HexPiece()
            }
        
            if (!(hexPiece is EnemyHexPiece)) {
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
        }
        
        return hexPiece!
    }

}
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
    var wildcardPercentage = 5
    
    // Chance to generate a mobile piece (moves around board until trapped)
    var mobilePercentage = 10
    
    // Chance to generate an enemy piece (moves around board until trapped)
    var enemyPercentage = 20
    
    // stack of pieces
    var pieceStack = Stack<HexPiece>()
    
    func getLevelHelperModeCaption(mode: LevelHelperMode) -> String {
        var caption = "Error"
        
        switch mode {
            case .Welcome:
                caption = "Tutorial"
            break
            case .Hexagon:
                caption = "Beginner"
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
        var randomStartingCount: Int = 10
        
        // Clear piece stack
        self.pieceStack.clear()
        
        // Process options
        self.mobilePercentage = GameState.instance!.getIntForKey("include_mobile_pieces", 1) == 1 ? 10 : 0
        self.enemyPercentage = GameState.instance!.getIntForKey("include_enemy_pieces", 1) == 1 ? (10 + self.mobilePercentage) : 0
        
        // Clear the hexMap
        hexMap.clear()
        
        switch mode {
            case .Welcome:
                // Create radius 2 hexagon
                let voidCells = Set(hexMap.getAllCells()).subtract(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2)+1)!, radius: 2)))
                
                for voidCell in voidCells {
                    voidCell.isVoid = true
                }
                
                // Disable random starting pieces
                randomStartingCount = 0
                
                // Generate tutorial pieces
                var piece: HexPiece = HexPiece()
                
                piece.value = 0
                piece.caption = "Welcome to Mergel! Start by tapping on the pulsing triangle."
                self.pushPiece(piece)
                
                piece = HexPiece()
                piece.value = 0
                piece.caption = "You can tap a shape to place it where it is, or tap an empty spot to place there instead."
                self.pushPiece(piece)
                
                piece = HexPiece()
                piece.value = 0
                piece.caption = "By forming a group of three or more of the same shape, they will merge to create the next shape in the series."
                self.pushPiece(piece)
                
                piece = MobileHexPiece()
                piece.value = 0
                piece.caption = "Some shapes are alive, and will move on their own until they are blocked."
                self.pushPiece(piece)
                
                piece = HexPiece()
                piece.value = 1
                piece.caption = "Sometimes, you get different shapes to play."
                self.pushPiece(piece)
                
                piece = EnemyHexPiece()
                piece.value = 0
                piece.caption = "Gel! The natural enemy of geometric shapes. Three gels become a bean, and three beans become collectible."
                self.pushPiece(piece)
                
                piece = WildcardHexPiece()
                piece.value = 0
                piece.caption = "Wildcard shapes will merge with any other shape, but not gel!"
                self.pushPiece(piece)
                
                piece = WildcardHexPiece()
                piece.value = 0
                piece.caption = "If you place a wildcard without merging, it will become a black star."
                self.pushPiece(piece)
                
                piece = self.getRandomPiece()
                piece.caption = "You can save a piece for later by tapping the Stash button. Try it!"
                self.pushPiece(piece)
                
                piece = self.getRandomPiece()
                piece.caption = "When you score points, you get 5% matching deposited in to your Bank."
                self.pushPiece(piece)
                
                piece = self.getRandomPiece()
                piece.caption = "If you get stuck, tap on the piggy bank to spend Bank Points on pieces."
                self.pushPiece(piece)
                
                piece = self.getRandomPiece()
                piece.caption = "Prices go up every time you buy something, and don't go back down until the game is over!"
                self.pushPiece(piece)
                
                piece = self.getRandomPiece()
                piece.caption = "If you make a mistake, you can use the undo button to take back your last move."
                self.pushPiece(piece)
                
                piece = HexPiece()
                piece.value = 0
                piece.caption = "When you're ready, tap the menu button and choose the Beginner map."
                self.pushPiece(piece)
                
                // Flip order so that newest pieces come off last
                self.pieceStack.reverseInPlace()
                
            break
            case .Hexagon:
                // Create radius 2 hexagon
                let voidCells = Set(hexMap.getAllCells()).subtract(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2)+1)!, radius: 2)))
                
                for voidCell in voidCells {
                    voidCell.isVoid = true
                }
            break
            case .Pit:
                // Start with a radius 3 hexagon
                var voidCells = Set(hexMap.getAllCells()).subtract(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 3)))
                
                // Void out radius 1 hexagon in middle
                voidCells = voidCells.union(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 1))
                
                for voidCell in voidCells {
                    voidCell.isVoid = true
                }
            break
            case .Moat:
                // Start with a radius 3 hexagon
                var voidCells = Set(hexMap.getAllCells()).subtract(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 3)))
                
                // Void out moat in center of hex map
                voidCells = voidCells.union(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 2)).subtract(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 1))))
                
                for voidCell in voidCells {
                    voidCell.isVoid = true
                }
                
                // add back left and right bridges
                hexMap.cell(1,3)!.isVoid = false
                hexMap.cell(5,3)!.isVoid = false
                
                // add four "towers"
                hexMap.cell(1,0)!.isVoid = false
                hexMap.cell(1,6)!.isVoid = false
                hexMap.cell(5,0)!.isVoid = false
                hexMap.cell(5,6)!.isVoid = false
            break
        }
        
        
        // Place some initial pieces
        if (randomStartingCount > 0) {
            for _ in 0...randomStartingCount {
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
    }
    
    /**
        Pops a piece off the stack, or generates a new random one if the stack is empty
    */
    func popPiece() -> HexPiece {
        if (self.pieceStack.count > 0) {
            return self.pieceStack.pop()
        } else {
            return self.getRandomPiece()
        }
    }
    
    /**
        Pushes a given HexPiece on to the stack
    */
    func pushPiece(piece: HexPiece) {
        self.pieceStack.push(piece)
    }
    
    /**
        Generates an instance of HexPiece with a random value, based on the set self.distribution.

        - Returns: Instance of HexPiece
    */
    func getRandomPiece() -> HexPiece {
        // Create a new hexPiece
        var hexPiece: HexPiece?
        
        let specialRoll = Int(arc4random_uniform(100)) + 1

        if (specialRoll<self.wildcardPercentage) { // Generate wildcard
            hexPiece = WildcardHexPiece()
        } else {
            if (specialRoll<self.mobilePercentage) { // Generate mobile
                hexPiece = MobileHexPiece()
            } else if (specialRoll<self.enemyPercentage) { // Generate enemy
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
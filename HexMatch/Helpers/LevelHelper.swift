//
//  LevelHelper.swift
//  HexMatch
//
//  Created by Josh McKee on 1/14/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

enum LevelHelperMode : Int {
    case welcome = 1
    case hexagon = 2
    case pit = 3
    case moat = 4
    case bighex = 5
    case debug = 99
}

class LevelHelper: NSObject {
    // singleton
    static let instance = LevelHelper()
    
    var mode: LevelHelperMode = .welcome    
    
    // Distribution of random piece values. Piece value is index in array, array member value is the pct chance the index will be selected.
    let distribution = [50, 30, 18, 2]
    
    // Chance to generate a wildcard piece (matches any value)
    var wildcardPercentage = 5
    
    // Chance to generate a mobile piece (moves around board until trapped)
    var mobilePercentage = 10
    
    // Chance to generate an enemy piece (moves around board until trapped)
    var enemyPercentage = 20
    
    // Minimum number of pre-generated pieces to keep in stack
    var minimumPieceCount = 5
    
    func getLevelHelperModeCaption(_ mode: LevelHelperMode) -> String {
        var caption = "Error"
        
        switch mode {
            case .welcome:
                caption = "Tutorial"
            break
            case .hexagon:
                caption = "Beginner"
            break
            case .pit:
                caption = "The Pit"
            break
            case .moat:
                caption = "The Moat"
            break
            case .bighex:
                caption = "Big Hex"
            break
            case .debug:
                caption = "Debug"
            break
        }
        
        return caption
    }

    /**
        Initializes a HexMap with a randomized starting layout

        - Parameters:
            - hexMap: Instance of HexMap to initialize
    */
    func initLevel(_ hexMap: HexMap) {
        var targetCell: HexCell? = nil
        var randomStartingCount: Int = 10
        
        // Clear piece stack
        GameState.instance!.pieceStack.clear()
        
        // Process options
        self.mobilePercentage = GameState.instance!.getIntForKey("include_mobile_pieces", 1) == 1 ? 10 : 0
        self.enemyPercentage = GameState.instance!.getIntForKey("include_enemy_pieces", 1) == 1 ? (10 + self.mobilePercentage) : 0
        
        // Clear the hexMap
        hexMap.clear()
        
        switch mode {
            case .debug:
                // Create radius 2 hexagon
                let voidCells = Set(hexMap.getAllCells()).subtracting(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2)+1)!, radius: 2)))
                
                for voidCell in voidCells {
                    voidCell.isVoid = true
                }
                
                // Disable random starting pieces
                randomStartingCount = 0
                
                var piece: HexPiece = HexPiece()
                
                piece = HexPiece()
                piece.value = 1
                self.pushPiece(piece)
                
                piece = HexPiece()
                piece.value = 2
                self.pushPiece(piece)
                
                piece = HexPiece()
                piece.value = 3
                self.pushPiece(piece)
                
                piece = HexPiece()
                piece.value = 4
                self.pushPiece(piece)
                
                piece = HexPiece()
                piece.value = 5
                self.pushPiece(piece)
                
                /*piece = WildcardHexPiece()
                piece.value = 0
                self.pushPiece(piece)
                
                piece = WildcardHexPiece()
                piece.value = 0
                self.pushPiece(piece)
                
                piece = WildcardHexPiece()
                piece.value = 0
                self.pushPiece(piece)*/

                
                // Flip order so that newest pieces come off last
                GameState.instance!.pieceStack.reverseInPlace()
            break
            case .welcome:
                // Create radius 2 hexagon
                let voidCells = Set(hexMap.getAllCells()).subtracting(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2)+1)!, radius: 2)))
                
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
                piece.value = 1000
                piece.caption = "Gel, enemy of geometric shapes. Three gels become a bean, and three beans become collectible."
                self.pushPiece(piece)
                
                piece = WildcardHexPiece()
                piece.value = 0
                piece.caption = "Wildcard shapes will merge with any other shape."
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
                GameState.instance!.pieceStack.reverseInPlace()
                
            break
            case .hexagon:
                // Create radius 2 hexagon
                let voidCells = Set(hexMap.getAllCells()).subtracting(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2)+1)!, radius: 2)))
                
                for voidCell in voidCells {
                    voidCell.isVoid = true
                }
            break
            case .pit:
                // Start with a radius 3 hexagon
                var voidCells = Set(hexMap.getAllCells()).subtracting(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 3)))
                
                // Void out radius 1 hexagon in middle
                voidCells = voidCells.union(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 1))
                
                for voidCell in voidCells {
                    voidCell.isVoid = true
                }
            break
            case .moat:
                // Start with a radius 3 hexagon
                var voidCells = Set(hexMap.getAllCells()).subtracting(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 3)))
                
                // Void out moat in center of hex map
                voidCells = voidCells.union(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 2)).subtracting(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 1))))
                
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
            case .bighex:
                // Increase random starting count
                randomStartingCount *= 2
                
                // Create radius 2 hexagon
                let voidCells = Set(hexMap.getAllCells()).subtracting(Set(hexMap.cellsForRadius(hexMap.cell(Int(hexMap.width/2),Int(hexMap.height/2))!, radius: 3)))
                
                for voidCell in voidCells {
                    voidCell.isVoid = true
                }
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
        if (GameState.instance!.pieceStack.count < self.minimumPieceCount) {
            for _ in GameState.instance!.pieceStack.count...self.minimumPieceCount {
                GameState.instance!.pieceStack.insert(self.getRandomPiece());
            }
        }
        
        let piece = GameState.instance!.pieceStack.pop()
        
        return piece
    }
    
    /**
        Pushes a given HexPiece on to the stack
    */
    func pushPiece(_ piece: HexPiece) {
        GameState.instance!.pieceStack.push(piece)
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
                hexPiece!.value = 1000
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
                    distributionIndex += 1
                    distributionCurrentValue = self.distribution[distributionIndex]
                    distributionAccumulatedValue += distributionCurrentValue
                }
                
                // Use the index of whatever value our loop ended at as the value of the new piece
                hexPiece!.value = distributionIndex
            }
        }
        
        return hexPiece!
    }

}

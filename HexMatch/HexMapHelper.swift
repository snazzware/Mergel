//
//  HexMapHelper.swift
//  HexMatch
//
//  Created by Josh McKee on 1/12/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//
import SpriteKit

class HexMapHelper: NSObject {
    // singleton
    static let instance = HexMapHelper()
    
    // Hex Map
    var hexMap: HexMap?
    
    // Collection of the sprites which were created to represent the hexmap
    var hexMapSprites: [[SKSpriteNode]] = Array()
    
    // Constants related to rendering of hex cell nodes
    let cellNodeHorizontalAdvance = 47
    let cellNodeVerticalAdvance = 54
    let cellNodeVerticalStagger = 27
    
    // Hex piece textures
    let hexPieceTextureNames = ["Triangle","Rhombus","Square","Pentagon","Hexagon","Star"]
    var maxPieceValue = 0
    var hexPieceTextures: [SKTexture] = Array()
    
    override init() {
        super.init()
        
        // Load each texture and store them for later use
        for textureName in hexPieceTextureNames {
            self.hexPieceTextures.append(SKTexture(imageNamed: textureName))
        }
        
        // set maximum value
        self.maxPieceValue = self.hexPieceTextureNames.count-1
    }
    
    /**
        Converts a hexmap co-ordinate to screen position

        - Parameters:
            - x: row of the hex cell
            - y: column of the hex cell

        - Returns: A CGPoint of the on-screen location of the hex cell
    */
    func hexMapToScreen(x: Int, _ y: Int) -> CGPoint {
        let x2 = self.cellNodeHorizontalAdvance * x
        var y2 = Int(CGFloat(self.cellNodeVerticalAdvance) * CGFloat(y))
        
        if (x % 2 != 0) {
            y2 -= self.cellNodeVerticalStagger
        }
        
        return CGPointMake(CGFloat(x2),CGFloat(y2))
    }
    
    /**
        Creates SKSpriteNode instances based on self.hexMap and adds them to a given parent SKNode. Each node is tracked in array hexMapSprites for later reference.

        - Parameters:
            - parent: The parent SKNode which will receive the hexmap's nodes

        - Returns: None
    */
    func renderHexMap(parent: SKNode) {
        let emptyCellTexture = SKTexture(imageNamed: "HexCell")
        let voidCellTexture = SKTexture(imageNamed: "HexCellVoid")
        
        var rows:[[SKSpriteNode]] = Array()
        
        for x in 0...self.hexMap!.width-1 {
            var rowSprites:[SKSpriteNode] = Array()
            for y in 0...self.hexMap!.height-1 {
                let hexCell = hexMap!.cell(x, y)
                
                var mapNode = SKSpriteNode(texture: emptyCellTexture)
                
                if (hexCell!.isVoid) {
                    mapNode = SKSpriteNode(texture: voidCellTexture)
                }
                
                // Name the node for convenience later
                mapNode.name = "hexMapCell"
                
                // We store the hex map x,y co-ordinate in the mapNode's userData dictionary so that
                // we can quickly know which cell was interacted with by the user (e.g. in the various thouch events)
                mapNode.userData = NSMutableDictionary()
                mapNode.userData!.setValue(x, forKey: "hexMapPositionX")
                mapNode.userData!.setValue(y, forKey: "hexMapPositionY")
                
                // Convert x,y to screen position
                mapNode.position = self.hexMapToScreen(x,y)
                
                // Add node to parent
                parent.addChild(mapNode)
                
                // Add node to our rows array (which gets rolled up in to self.hexMapSprites)
                rowSprites.append(mapNode)
                
                // Render piece, if any, and add to parent
                if (hexCell!.hexPiece != nil) {
                    let hexPieceSprite = self.createHexPieceSprite(hexCell!.hexPiece!)
                    
                    hexPieceSprite.position = mapNode.position
                    hexPieceSprite.zPosition = 2
                    
                    hexCell!.hexPiece!.sprite = hexPieceSprite
                    
                    parent.addChild(hexPieceSprite)
                }
            }
            
            // Add nodes from the row to our columns array (which becomes self.hexMapSprites)
            rows.append(rowSprites)
        }
        
        self.hexMapSprites = rows
    }
    
    func clearHexMap(parent: SKNode) {
        for childNode in parent.children {
            if (childNode.name == "hexPiece" || childNode.name == "hexMapCell") {
                childNode.removeFromParent()
            }
        }
    }
    
    func createHexPieceSprite(hexPiece: HexPiece) -> SKSpriteNode {
        let node = SKSpriteNode(texture: self.hexPieceTextures[hexPiece.value])
        
        node.name = "hexPiece"
        
        return node
    }
}

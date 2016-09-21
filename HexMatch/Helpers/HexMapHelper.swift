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
    
    // Debugging
    let displayCellCoordinates = false
    
    // Hex Map
    var hexMap: HexMap?
    
    // Formatter
    let scoreFormatter = NumberFormatter()
    
    //
    var addedCounter = 0
    
    // Collection of the sprites which were created to represent the hexmap
    var hexMapSprites: [[SKSpriteNode]] = Array()
    
    // Constants related to rendering of hex cell nodes
    let cellNodeHorizontalAdvance = 44
    let cellNodeVerticalAdvance = 50
    let cellNodeVerticalStagger = 25
    
    // Actual height/width dimensions of each cell
    let cellActualHeight = 59
    let cellActualWidth = 60
    
    // Offsets
    let offsetLeft = 30
    let offsetBottom = 60
    
    // Bounds
    var renderedBounds = CGRect(x: 0,y: 0,width: 0,height: 0)
    
    // Hex piece textures
    let hexPieceTextureNames = ["Triangle","Square","Pentagon","Hexagon","Star","GoldStar","CollectibleGoldStar"]
    var maxPieceValue = 0
    var hexPieceTextures: [SKTexture] = Array()
    
    // Wildcard 
    let wildcardPieceTextureNames = ["Wildcard"]
    var wildcardPieceTextures: [SKTexture] = Array()
    
    let wildcardPlacedTextureName = "Blackstar"
    var wildcardPlacedTexture: SKTexture?
    let wildcardPlacedValue = 10
    
    override init() {
        super.init()
        
        // set up score formatter
        self.scoreFormatter.numberStyle = .decimal
        
        // Load each texture and store them for later use
        for textureName in hexPieceTextureNames {
            self.hexPieceTextures.append(SKTexture(imageNamed: textureName))
        }
        
        // Load wildcard texture(s)
        for textureName in wildcardPieceTextureNames {
            self.wildcardPieceTextures.append(SKTexture(imageNamed: textureName))
        }
        
        // Load wildcard placed texture
        self.wildcardPlacedTexture = SKTexture(imageNamed: self.wildcardPlacedTextureName)
        
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
    func hexMapToScreen(_ x: Int, _ y: Int) -> CGPoint {
        let offsetX = x - Int(self.renderedBounds.origin.x)
        let offsetY = y - Int(self.renderedBounds.origin.y)
    
        let x2 = self.cellNodeHorizontalAdvance * offsetX
        var y2 = Int(CGFloat(self.cellNodeVerticalAdvance) * CGFloat(offsetY))
        
        if (x % 2 != 0) {
            y2 -= self.cellNodeVerticalStagger
        }
        
        return CGPoint(x: CGFloat(x2+self.offsetLeft),y: CGFloat(y2+self.offsetBottom))
    }
    
    func hexMapToScreen(_ position: HCPosition) -> CGPoint {
        return self.hexMapToScreen(position.x, position.y)
    }
    
    func getBounds() -> CGRect {
        var bounds = CGRect(x: -1,y: -1,width: -1,height: -1)
        
        for x in 0...self.hexMap!.width-1 {
            for y in 0...self.hexMap!.height-1 {
                if (!(hexMap!.cell(x, y)!.isVoid)) {
                    // Set origin x and y
                    if (bounds.origin.x == -1 || bounds.origin.x > CGFloat(x)) {
                        bounds.origin.x = CGFloat(x)
                    }
                    if (bounds.origin.y == -1 || bounds.origin.y > CGFloat(y)) {
                        bounds.origin.y = CGFloat(y)
                    }
                    
                    // Update width & height
                    if (abs(CGFloat(x) - bounds.origin.x) > bounds.size.width) {
                        bounds.size.width = abs(CGFloat(x) - bounds.origin.x)+1
                    }
                    if (abs(CGFloat(y) - bounds.origin.y) > bounds.size.height) {
                        bounds.size.height = abs(CGFloat(y) - bounds.origin.y)+1
                    }
                }
            }
        }
        
        return bounds
    }
    
    func getRenderedWidth() -> CGFloat {
        let bounds = self.getBounds()
        
        return CGFloat(CGFloat(self.cellNodeHorizontalAdvance)*(bounds.size.width)) + CGFloat(self.cellActualWidth - self.cellNodeHorizontalAdvance)
    }
    
    func getRenderedHeight() -> CGFloat {
        let bounds = self.getBounds()
        
        return CGFloat(CGFloat(self.cellActualHeight)*(bounds.size.height)) - CGFloat(self.cellActualHeight - self.cellNodeVerticalAdvance)
    }
    
    /**
        Creates SKSpriteNode instances based on self.hexMap and adds them to a given parent SKNode. Each node is tracked in array hexMapSprites for later reference.

        - Parameters:
            - parent: The parent SKNode which will receive the hexmap's nodes

        - Returns: None
    */
    func renderHexMap(_ parent: SKNode) {
        let emptyCellTexture = SKTexture(imageNamed: "HexCell")
        let voidCellTexture = SKTexture(imageNamed: "HexCellVoid")
        
        var rows:[[SKSpriteNode]] = Array()
        
        // Calculate current bounds
        self.renderedBounds = self.getBounds()
    
        // Render the shadow
        self.renderHexMapShadow(parent);
    
        // Iterate over map and render each cell
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
                    let hexPieceSprite = hexCell!.hexPiece!.createSprite()
                    
                    hexPieceSprite.position = mapNode.position
                    hexPieceSprite.zPosition = 2
                    
                    hexCell!.hexPiece!.sprite = hexPieceSprite
                    
                    parent.addChild(hexPieceSprite)
                }
                
                if (self.displayCellCoordinates) {
                    let positionSprite = SKLabelNode(text: "\(x),\(y)")
                    positionSprite.zPosition = 10000
                    mapNode.addChild(positionSprite)
                }
            }
            
            // Add nodes from the row to our columns array (which becomes self.hexMapSprites)
            rows.append(rowSprites)
        }
        
        self.hexMapSprites = rows
    }
    
    
    func renderHexMapShadow(_ parent: SKNode) {
        let emptyCellTexture = SKTexture(imageNamed: "HexCellShadow")
        let voidCellTexture = SKTexture(imageNamed: "HexCellVoid")
        
        for x in 0...self.hexMap!.width-1 {
            for y in 0...self.hexMap!.height-1 {
                let hexCell = hexMap!.cell(x, y)
                
                var mapNode = SKSpriteNode(texture: emptyCellTexture)
                
                mapNode.zPosition = -1
                
                if (hexCell!.isVoid) {
                    mapNode = SKSpriteNode(texture: voidCellTexture)
                }
                
                // Name the node for convenience later
                mapNode.name = "hexMapCellShadow"
                
                // Convert x,y to screen position
                mapNode.position = self.hexMapToScreen(x,y)
                
                // Add node to parent
                parent.addChild(mapNode)
            }
        }
    }
    
    func clearHexMap(_ parent: SKNode) {
        for childNode in parent.children {
            if (childNode.name == "hexPiece" || childNode.name == "hexMapCell" || childNode.name == "hexMapCellShadow") {
                childNode.removeFromParent()
            }
        }
    }
    
    
    
    /**
        Creates a sprite to represent a wildcard piece

        - Parameters:
            - hexPiece: The hexPiece instance for which the sprite is being created
            
        - Returns: Instance of SKSpriteNode
    */
    func createWildCardSprite(_ hexPiece: HexPiece) -> SKSpriteNode {
        let node = SKSpriteNode(texture: self.hexPieceTextures.first)
        node.name = "hexPiece"
        
        node.run(
            SKAction.repeatForever(
                SKAction.animate(
                    with: self.wildcardPieceTextures,
                    timePerFrame: 0.2,
                    resize: false,
                    restore: true
                )
            ),
            withKey:"wildcardAnimation"
        )
        
        return node
    }
    
    func getFirstMerge() -> [HexPiece] {
        var merged: [HexPiece] = Array()
        
        let occupiedCells = self.hexMap?.getOccupiedCells()
        
        if (occupiedCells != nil) {
            for occupiedCell in occupiedCells! {
                if (occupiedCell.hexPiece != nil) {
                    merged = occupiedCell.getWouldMergeWith(occupiedCell.hexPiece!)
                    
                    if (merged.count>0) {
                        merged.append(occupiedCell.hexPiece!)
                        break;
                    }
                }
            }
        }
        
        return merged
    }
}

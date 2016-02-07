//
//  HexCell.swift
//  HexMatch
//
//  Created by Josh McKee on 1/12/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

enum HexCellDirection {
    case North, South, NorthEast, NorthWest, SouthEast, SouthWest
    
    static let allDirections = [North, South, NorthEast, NorthWest, SouthEast, SouthWest]
}

enum MergeStyle : String {
    case Liner = "Liner"
    case Cluster = "Cluster"
}

class HexCell : NSObject, NSCoding {
    //var x: Int
    //var y: Int
    var position: HCPosition
    var isVoid = false
    
    var mergeStyle: MergeStyle = .Cluster
    
    var hexMap: HexMap
    
    var _hexPiece: HexPiece?
    var hexPiece: HexPiece? {
        get {
            return self._hexPiece
        }
        set {
            // unlink any existing piece
            if (self._hexPiece != nil) {
                self._hexPiece!.hexCell = nil
            }
            
            // update value
            self._hexPiece = newValue
            
            // link to new piece
            if (self._hexPiece != nil) {
                self._hexPiece!.hexCell = self
                
                // map is no longer blank
                self.hexMap.isBlank = false
            }
        }
    }
    
    init(_ map: HexMap, _ x: Int, _ y: Int) {
        self.position = HCPosition(x, y)
        self.hexMap = map
    }
    
    func getCellByDirection(direction: HexCellDirection) -> HexCell? {
        switch direction {
            case HexCellDirection.North:
                return self.north
            case HexCellDirection.South:
                return self.south
            case HexCellDirection.SouthEast:
                return self.southEast
            case HexCellDirection.SouthWest:
                return self.southWest
            case HexCellDirection.NorthEast:
                return self.northEast
            case HexCellDirection.NorthWest:
                return self.northWest
        }
    }
    
    var north:HexCell? {
        get {
            return self.hexMap.cell(self.position.north)
        }
    }
    
    var northEast:HexCell? {
        get {
            return self.hexMap.cell(self.position.northEast)
        }
    }
    
    var northWest:HexCell? {
        get {
            return self.hexMap.cell(self.position.northWest)
        }
    }
    
    var south:HexCell? {
        get {
            return self.hexMap.cell(self.position.south)
        }
    }
    
    var southEast:HexCell? {
        get {
            return self.hexMap.cell(self.position.southEast)
        }
    }
    
    var southWest:HexCell? {
        get {
            return self.hexMap.cell(self.position.southWest)
        }
    }
    
    override var description: String {
        return "HexCell \(self.position)"
    }
    
    /**
        Determines if this cell will accept a given HexPiece

        - Parameters:
            - hexPiece: The piece to be tested

        - Returns: True if this cell will accept the piece, false otherwise
    */
    func willAccept(hexPiece: HexPiece) -> Bool {
        return self.isOpen()
    }
    
    func isOpen() -> Bool {
        return (!self.isVoid && self.hexPiece == nil)
    }
    
    /**
        Recursively checks for valid merges in every direction for a given HexPiece, skipping cells which have already
        been checked as part of the current recursion.
    */
    func getClusterMerges(hexPiece: HexPiece, var _ visitedCells: [HexCell]) -> [HexPiece] {
        var merges: [HexPiece] = Array()
    
        for direction in HexCellDirection.allDirections {
            let targetCell = self.getCellByDirection(direction)
            
            if (targetCell != nil && !visitedCells.contains(targetCell!)) {
                visitedCells.append(targetCell!)
                if (targetCell != nil && targetCell!.hexPiece != nil && targetCell!.hexPiece!.canMergeWithPiece(hexPiece) && hexPiece.canMergeWithPiece(targetCell!.hexPiece!)) {
                    merges.append(targetCell!.hexPiece!)
                    merges += targetCell!.getClusterMerges(hexPiece, visitedCells)
                }
            }
        }
        
        return merges
    }
    
    /**
        Iterates over each direction from this cell, looking for runs of pieces which canMergeWithPiece(hexPiece) is true.
        If a merge is detected, the function recurses to detect further matches with the incremented value piece.

        - Parameters:
            - hexPiece: The piece to be tested

        - Returns: Set of HexPieces which would be merged (if any), or empty if none
    */
    func getWouldMergeWith(hexPiece: HexPiece) -> [HexPiece] {
        var merges: [HexPiece] = Array()
        
        // Number of same pieces we found searching all directions
        var samePieceCount = 0
        
        let firstValue = hexPiece.getMinMergeValue()
        let lastValue = hexPiece.getMaxMergeValue()
        
        var value = lastValue
        
        // Loop over possible values for the piece being placed, starting with highest, until we find a merge
        while (samePieceCount<2 && value >= firstValue) {
            merges.removeAll()
            
            samePieceCount = 0
            
            hexPiece.value = value
            
            switch (self.mergeStyle) {
                case .Liner:
                    // Iterate over all directions, following each direction as long as there is a matching piece value
                    for direction in HexCellDirection.allDirections {
                        var targetCell = self.getCellByDirection(direction)
                        while (targetCell != nil && targetCell!.hexPiece != nil && targetCell!.hexPiece!.canMergeWithPiece(hexPiece) && hexPiece.canMergeWithPiece(targetCell!.hexPiece!)) {
                            merges.append(targetCell!.hexPiece!)
                            samePieceCount++
                            targetCell = targetCell!.getCellByDirection(direction)
                        }
                    }
                break
                case .Cluster:
                    var visitedCells: [HexCell] = Array()
                    
                    // Prevent visiting self
                    visitedCells.append(self)
                    
                    // Recurse and find merges
                    merges += self.getClusterMerges(hexPiece, visitedCells)
                    
                    samePieceCount = merges.count
                break
            }
            
            value--;
        }
        
        // If we didn't get at least two of the same piece, clear our merge array
        if (samePieceCount < 2) {
            merges.removeAll()
        } else {
            // If we DID get at least two, recurse with the new piece
            if (hexPiece.value<HexMapHelper.instance.maxPieceValue) {
                if (hexPiece is WildcardHexPiece) { // create a copy if we're dealing with a wildcard
                    let mergedPiece = HexPiece()
                    mergedPiece.value = hexPiece.value+1
                    merges += self.getWouldMergeWith(mergedPiece)
                } else { // try next merge with updated value
                    hexPiece.updateValueForMergeTest()
                    
                    merges += self.getWouldMergeWith(hexPiece)
                    
                    hexPiece.rollbackValueForMergeTest()
                }
            }
        }        
        
        return merges
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let x = (decoder.decodeObjectForKey("x") as? Int)!
        let y = (decoder.decodeObjectForKey("y") as? Int)!
        let hexMap = (decoder.decodeObjectForKey("hexMap") as? HexMap)!
        
        self.init(hexMap, x, y)
        
        self.isVoid = (decoder.decodeObjectForKey("isVoid") as? Bool)!
        
        self.mergeStyle = MergeStyle(rawValue: (decoder.decodeObjectForKey("mergeStyle") as! String))!
        
        self.hexPiece = (decoder.decodeObjectForKey("hexPiece") as? HexPiece)
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.position.x, forKey: "x")
        coder.encodeObject(self.position.y, forKey: "y")
        coder.encodeObject(self.hexMap, forKey: "hexMap")
        
        coder.encodeObject(self.isVoid, forKey: "isVoid")
        
        coder.encodeObject(self.mergeStyle.rawValue, forKey: "mergeStyle")
        
        coder.encodeObject(self.hexPiece, forKey: "hexPiece")
    }
    
}
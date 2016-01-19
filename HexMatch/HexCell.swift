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

class HexCell : NSObject {
    var x: Int
    var y: Int
    var isVoid = false
    
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
            }
        }
    }
    
    init(_ map: HexMap, _ x: Int, _ y: Int) {
        self.x = x
        self.y = y
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
            return self.hexMap.cell(x,y+1)
        }
    }
    
    var northEast:HexCell? {
        get {
            if (x % 2 == 0) { // even
                return self.hexMap.cell(x+1,y+1)
            } else {
                return self.hexMap.cell(x+1,y)
            }
        }
    }
    
    var northWest:HexCell? {
        get {
            if (x % 2 == 0) { // even
                return self.hexMap.cell(x-1,y+1)
            } else {
                return self.hexMap.cell(x-1,y)
            }
        }
    }
    
    var south:HexCell? {
        get {
            return self.hexMap.cell(x,y-1)
        }
    }
    
    var southEast:HexCell? {
        get {
            if (x % 2 == 0) { // even
                return self.hexMap.cell(x+1,y)
            } else {
                return self.hexMap.cell(x+1,y-1)
            }
        }
    }
    
    var southWest:HexCell? {
        get {
            if (x % 2 == 0) { // even
                return self.hexMap.cell(x-1,y)
            } else {
                return self.hexMap.cell(x-1,y-1)
            }
        }
    }
    
    override var description: String {
        return "HexCell \(x) \(y)"
    }
    
    /**
        Determines if this cell will accept a given HexPiece

        - Parameters:
            - hexPiece: The piece to be tested

        - Returns: True if this cell will accept the piece, false otherwise
    */
    func willAccept(hexPiece: HexPiece) -> Bool {
        if (!self.isVoid && self.hexPiece == nil) {
            return true
        } else {
            return false
        }
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
            
            // Iterate over all directions, following each direction as long as there is a matching piece value
            for direction in HexCellDirection.allDirections {
                var targetCell = self.getCellByDirection(direction)
                while (targetCell != nil && targetCell!.hexPiece != nil && targetCell!.hexPiece!.canMergeWithPiece(hexPiece)) {
                    merges.append(targetCell!.hexPiece!)
                    samePieceCount++
                    targetCell = targetCell!.getCellByDirection(direction)
                }
            }
            
            value--;
        }
        
        // If we didn't get at least two of the same piece, clear our merge array
        if (samePieceCount < 2) {
            merges.removeAll()
        } else {
            // If we DID get at least two, recurse with the new piece
            if (hexPiece.value<HexMapHelper.instance.maxPieceValue) {
                let mergedPiece = HexPiece()
                mergedPiece.value = hexPiece.value+1
                
                merges += self.getWouldMergeWith(mergedPiece)
            }
        }
        
        return merges
    }
    
}
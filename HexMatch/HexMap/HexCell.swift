//
//  HexCell.swift
//  HexMatch
//
//  Created by Josh McKee on 1/12/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

enum HexCellDirection {
    case north, south, northEast, northWest, southEast, southWest
    
    static let allDirections = [north, south, northEast, northWest, southEast, southWest]
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
    
    func getCellByDirection(_ direction: HexCellDirection) -> HexCell? {
        switch direction {
            case HexCellDirection.north:
                return self.north
            case HexCellDirection.south:
                return self.south
            case HexCellDirection.southEast:
                return self.southEast
            case HexCellDirection.southWest:
                return self.southWest
            case HexCellDirection.northEast:
                return self.northEast
            case HexCellDirection.northWest:
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
    func willAccept(_ hexPiece: HexPiece) -> Bool {
        return self.isOpen()
    }
    
    func isOpen() -> Bool {
        return (!self.isVoid && self.hexPiece == nil)
    }
    
    /**
        Recursively checks for valid merges in every direction for a given HexPiece, skipping cells which have already
        been checked as part of the current recursion.
    */
    func getClusterMerges(_ hexPiece: HexPiece, _ visitedCells: [HexCell]) -> [HexPiece] {
        var merges: [HexPiece] = Array()
        var localVisitedCells = visitedCells
    
        for direction in HexCellDirection.allDirections {
            let targetCell = self.getCellByDirection(direction)
            
            if (targetCell != nil && !localVisitedCells.contains(targetCell!)) {
                localVisitedCells.append(targetCell!)
                if (targetCell != nil && targetCell!.hexPiece != nil && targetCell!.hexPiece!.canMergeWithPiece(hexPiece) && hexPiece.canMergeWithPiece(targetCell!.hexPiece!)) {
                    merges.append(targetCell!.hexPiece!)
                    merges += targetCell!.getClusterMerges(hexPiece, localVisitedCells)
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
    func getWouldMergeWith(_ hexPiece: HexPiece) -> [HexPiece] {
        var merges: [HexPiece] = Array()
        
        // Number of same pieces we found searching all directions
        var samePieceCount = 0
        
        let firstValue = hexPiece.getMinMergeValue()
        let lastValue = hexPiece.getMaxMergeValue()
        var neighborValues: [Int] = Array()
        
        // Get values of all of our neighbors, for iteration, where value is between our piece's firstValue and lastValue
        for direction in HexCellDirection.allDirections {
            let targetCell = self.getCellByDirection(direction)
            if (targetCell != nil && targetCell!.hexPiece != nil && !neighborValues.contains(targetCell!.hexPiece!.value) && (firstValue <= targetCell!.hexPiece!.value && lastValue >= targetCell!.hexPiece!.value)) {
                neighborValues.append(targetCell!.hexPiece!.value)
            }
        }
        
        // Sort ascending
        neighborValues = neighborValues.sorted { $0 < $1 }
        
        // Get last (largest) value
        var value = neighborValues.popLast()
        
        // Loop over possible values for the piece being placed, starting with highest, until we find a merge
        while (samePieceCount<2 && value != nil) {
            merges.removeAll()
            
            samePieceCount = 0
            
            hexPiece.value = value!
            
            switch (self.mergeStyle) {
                case .Liner:
                    // Iterate over all directions, following each direction as long as there is a matching piece value
                    for direction in HexCellDirection.allDirections {
                        var targetCell = self.getCellByDirection(direction)
                        while (targetCell != nil && targetCell!.hexPiece != nil && targetCell!.hexPiece!.canMergeWithPiece(hexPiece) && hexPiece.canMergeWithPiece(targetCell!.hexPiece!)) {
                            merges.append(targetCell!.hexPiece!)
                            samePieceCount += 1
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
            
            value = neighborValues.popLast()
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
        let x = decoder.decodeInteger(forKey: "x")
        let y = decoder.decodeInteger(forKey: "y")
        let hexMap = (decoder.decodeObject(forKey: "hexMap") as? HexMap)!
        
        self.init(hexMap, x, y)
        
        self.isVoid = decoder.decodeBool(forKey: "isVoid")
        
        self.mergeStyle = MergeStyle(rawValue: (decoder.decodeObject(forKey: "mergeStyle") as! String))!
        
        self.hexPiece = (decoder.decodeObject(forKey: "hexPiece") as? HexPiece)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.position.x, forKey: "x")
        coder.encode(self.position.y, forKey: "y")
        coder.encode(self.hexMap, forKey: "hexMap")
        
        coder.encode(self.isVoid, forKey: "isVoid")
        
        coder.encode(self.mergeStyle.rawValue, forKey: "mergeStyle")
        
        coder.encode(self.hexPiece, forKey: "hexPiece")
    }
    
}

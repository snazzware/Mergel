//
//  HexMap.swift
//  HexMatch
//
//  Created by Josh McKee on 1/12/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

class HexMap : NSObject, NSCoding {
    
    var cells: [[HexCell]] = Array()
    var width: Int = 0
    var height: Int = 0
    var isBlank = true
    
    /**
        Initializes a new HexMap.

        - Parameters:
            - width: How many cells wide the HexMap will be
            - height: How many cells tall the HexMap will be

        - Returns: A new instance of HexMap, initialized with width*height HexCell instances
    */
    init(_ width: Int, _ height: Int) {
        super.init()
    
        self.width = width
        self.height = height
        
        var rows:[[HexCell]] = Array()

        for x in 0...self.width-1 {
            var rowCells:[HexCell] = Array()
            for y in 0...self.height-1 {
                rowCells.append(HexCell(self,x,y))
            }
            rows.append(rowCells)
        }
        
        self.cells = rows

    }
    
    /**
        Resets hexMap back to starting conditions
    */
    func clear() {
        for x in 0...self.width-1 {
            for y in 0...self.height-1 {
                self.cells[x][y].hexPiece = nil
                self.cells[x][y].isVoid = false
            }
        }
        
        self.isBlank = true
    }
    
    /**
        Scans cell array and generates a set of cells which are open.
        
        - Returns: Array of HexCells which are open (i.e. do not contain a piece)
    */
    func getOpenCells() -> [HexCell] {
        var openCells:[HexCell] = Array();
        
        for x in 0...self.width-1 {
            for y in 0...self.height-1 {
                if (self.cells[x][y].isOpen()) {
                    openCells.append(self.cells[x][y]);
                }
            }
        }
                
        return openCells;
    }
    
    /**
        Scans cell array and generates a set of cells which are not open.
        
        - Returns: Array of HexCells which are not open (i.e. contain a piece)
    */
    func getOccupiedCells() -> [HexCell] {
        var occupiedCells:[HexCell] = Array();
        
        for x in 0...self.width-1 {
            for y in 0...self.height-1 {
                if (!self.cells[x][y].isOpen()) {
                    occupiedCells.append(self.cells[x][y]);
                }
            }
        }
                
        return occupiedCells;
    }
    
    /**
        Fetches a cell from the HexMap

        - Parameters:
            - x: The x co-ordinate of the desired cell (zero based)
            - y: The y co-ordinate of the desired cell (zero based)

        - Returns: An instance of HexCell, or nil if x,y were out-of-bounds
    */
    func cell(_ x: Int, _ y: Int) -> HexCell? {
        if ((x >= 0 && x < width) && (y >= 0 && y < height)) {
            return self.cells[x][y];
        } else {
            return nil;
        }
    }
    
    func cell(_ position: HCPosition) -> HexCell? {
        return self.cell(position.x, position.y)
    }
    
    /**
        Generates a set of all hexcells in the HexMap's cells array.
        
        - Returns: Array of all HexCells
    */
    func getAllCells() -> [HexCell] {
        var allCells:[HexCell] = Array();
        
        for x in 0...self.width-1 {
            for y in 0...self.height-1 {
                allCells.append(self.cells[x][y]);
            }
        }
                
        return allCells;
    }
    
    /**
        Generates a set of all hex cells in a given radius from a given center cell
        
        - Returns: Array of HexCells
    */
    func cellsForRadius(_ center: HexCell, radius: Int) -> [HexCell] {
        if (radius == 0) {
            return [center]
        }

        // hex radius testing
        var cells = [HexCell]()
        
        // Middle
        for i in (center.position.y-radius)...(center.position.y+radius) {
            let targetCell = self.cell(center.position.x,i)
            if (targetCell != nil) {
                cells.append(targetCell!)
            }
        }
        
        let centerPosition = center.position
        
        // East/West
        var currentWest = centerPosition.northWest
        var currentEast = centerPosition.northEast
        
        for i in 1...radius {
            for j in (0-(radius-i))...radius {
                var targetCell: HexCell?

                targetCell = self.cell(currentWest.x,currentWest.y-j)
                if (targetCell != nil) {
                    cells.append(targetCell!)
                }
            
                targetCell = self.cell(currentEast.x,currentEast.y-j)
                if (targetCell != nil) {
                    cells.append(targetCell!)
                }
            }
                                
            currentWest = currentWest.northWest
            currentEast = currentEast.northEast
        }
        
        // Return cells, filtered to remove any nil values
        return cells.filter{ $0 != nil }
    }
    
    /**
        Generates a set of open Hex Cells in a given radius from a given center cell.
        
        - Returns: Array of HexCells
    */
    func openCellsForRadius(_ center: HexCell, radius: Int) -> [HexCell] {
        return self.cellsForRadius(center, radius: radius).filter{
            ($0 != nil) && ($0 as HexCell).isOpen()
        }
    }

    /**
        Attempts to locate a random open hex cell near a given center cell, starting at radius 1 and searching outward
        until a maximum of the HexMap's width divided by two, or the height divided by two, whichever is greater.
        
        - Returns: HexCell, or nil if none was found
    */
    func getRandomCellNear(_ center: HexCell) -> HexCell? {
        var radius = 1;
        var randomCell: HexCell?
        
        let xRadius = Int(ceil(Double(self.width) / 2))
        let yRadius = Int(ceil(Double(self.height) / 2))
        
        let maxRadius = xRadius > yRadius ? xRadius : yRadius
        
        while (randomCell == nil && radius < maxRadius) {
            let openCells = self.openCellsForRadius(center, radius: radius)
            
            if (openCells.count > 0) {
                randomCell = openCells[Int(arc4random_uniform(UInt32(openCells.count)))]
            }
            
            radius += 1
        }
        
        if (randomCell == nil) {
            randomCell = self.getRandomCell()
        }
        
        return randomCell
    }
    
    /**
        - Returns: An open HexCell, or nil if no open cells exist
     */
    func getRandomCell() -> HexCell? {
        var randomCell: HexCell?
        let openCells = self.getOpenCells()
        
        if (openCells.count > 0) {
            randomCell = openCells[Int(arc4random_uniform(UInt32(openCells.count)))]
        }
        
        return randomCell
    }

    required convenience init?(coder decoder: NSCoder) {
        let width = decoder.decodeInteger(forKey: "width")
        let height = decoder.decodeInteger(forKey: "height")
    
        self.init(width,height)
        
        let cells = decoder.decodeObject(forKey: "cells")
        if (cells != nil) {
            self.cells = (cells as? [[HexCell]])!
        } else {
            self.cells = [[HexCell]]()
        }
        
        if (decoder.containsValue(forKey: "isBlank")) {
            self.isBlank = decoder.decodeBool(forKey: "isBlank")
        } else {
            self.isBlank = true
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.width, forKey: "width")
        coder.encode(self.height, forKey: "height")
        
        coder.encode(self.cells, forKey: "cells")
        
        coder.encode(self.isBlank, forKey: "isBlank")
    }
    
}

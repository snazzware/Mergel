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
    }
    
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
    func cell(x: Int, _ y: Int) -> HexCell? {
        if ((x >= 0 && x < width) && (y >= 0 && y < height)) {
            return self.cells[x][y];
        } else {
            return nil;
        }
    }
    
    func cellsForRadius(center: HexCell, radius: Int) -> [HexCell] {
        if (radius == 0) {
            return [center]
        }

        // hex radius testing
        var cells = [HexCell]()
        
        // Middle
        for i in (center.y-radius)...(center.y+radius) {
            let targetCell = self.cell(center.x,i)
            if (targetCell != nil) {
                cells.append(targetCell!)
            }
        }
        
        // East/West
        var currentWest = center.northWest
        var currentEast = center.northEast
        
        for i in 1...radius {
            for j in ((radius-i))...radius {
                var targetCell: HexCell?

                if (currentWest != nil) {
                    targetCell = self.cell(currentWest!.x,currentWest!.y-j)
                    if (targetCell != nil) {
                        cells.append(targetCell!)
                    }
                }
                if (currentEast != nil) {
                    targetCell = self.cell(currentEast!.x,currentEast!.y-j)
                    if (targetCell != nil) {
                        cells.append(targetCell!)
                    }
                }
            }
            
            if (currentWest != nil) {
                currentWest = currentWest!.northWest
            }
            
            if (currentEast != nil) {
                currentEast = currentEast!.northEast
            }
        }
        
        // Return cells, filtered to remove any nil values
        return cells.filter{ $0 != nil }
    }
    
    func openCellsForRadius(center: HexCell, radius: Int) -> [HexCell] {
        return self.cellsForRadius(center, radius: radius).filter{
            ($0 != nil) && ($0 as HexCell).isOpen()
        }
    }

    required convenience init?(coder decoder: NSCoder) {
    
        let width = (decoder.decodeObjectForKey("width") as? Int)!
        let height = (decoder.decodeObjectForKey("height") as? Int)!
    
        self.init(width,height)
        
    }
    
    func encodeWithCoder(coder: NSCoder) {
    }
    
}
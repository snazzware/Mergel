//
//  HexCellTest.swift
//  HexMatch
//
//  Created by Josh McKee on 1/12/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import XCTest
@testable import Mergel

class HexCellTest: XCTestCase {

    var hexMap: HexMap?
    
    override func setUp() {
        self.hexMap = HexMap(7,7)
    }

    func testHexCellDirectionsOddColumn() {
        let centerCell = self.hexMap!.cell(3,3);
        
        XCTAssertTrue(centerCell!.north == self.hexMap!.cell(3,4))
        XCTAssertTrue(centerCell!.northEast == self.hexMap!.cell(4,3))
        XCTAssertTrue(centerCell!.southEast == self.hexMap!.cell(4,2))
        XCTAssertTrue(centerCell!.south == self.hexMap!.cell(3,2))
        XCTAssertTrue(centerCell!.southWest == self.hexMap!.cell(2,2))
        XCTAssertTrue(centerCell!.northWest == self.hexMap!.cell(2,3))
    }
    
    func testHexCellDirectionsEvenColumn() {
        let centerCell = self.hexMap!.cell(4,3);
        
        XCTAssertTrue(centerCell!.north == self.hexMap!.cell(4,4))
        XCTAssertTrue(centerCell!.northEast == self.hexMap!.cell(5,4))
        XCTAssertTrue(centerCell!.southEast == self.hexMap!.cell(5,3))
        XCTAssertTrue(centerCell!.south == self.hexMap!.cell(4,2))
        XCTAssertTrue(centerCell!.southWest == self.hexMap!.cell(3,3))
        XCTAssertTrue(centerCell!.northWest == self.hexMap!.cell(3,4))
    }

}

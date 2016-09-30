//
//  HexMapTest.swift
//  HexMatch
//
//  Created by Josh McKee on 1/12/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import XCTest
@testable import Mergel

class HexMapTest: XCTestCase {

    func testHexMapBounds() {
        let hexMap = HexMap(10,5);
        
        // 9,4 should be a valid cell
        XCTAssertNotNil(hexMap.cell(9,4));

        // 10,5 is out of bounds and should be invalid
        XCTAssertNil(hexMap.cell(10,5));
        
        // -1,0 is out of bounds and should be invalid
        XCTAssertNil(hexMap.cell(-1,0));
        

    }

}

//
//  SNZGenerics.swift
//  HexMatch
//
//  Created by Josh McKee on 2/10/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

struct Stack<Element> {
    var items = [Element]()
    
    var count: Int {
        get {
            return self.items.count
        }
    }
    
    mutating func push(item: Element) {
        self.items.append(item)
    }
    
    mutating func insert(item: Element, index: Int = 0) {
        self.items.insert(item, atIndex: index)
    }
    
    mutating func pop() -> Element {
        return self.items.removeLast()
    }
    
    mutating func clear() {
        self.items.removeAll()
    }
    
    mutating func reverseInPlace() {
        self.items = self.items.reverse()
    }
}
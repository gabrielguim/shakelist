//
//  Item.swift
//  Shake list
//
//  Created by Student on 3/21/17.
//  Copyright © 2017 Student. All rights reserved.
//

import Foundation

class Item {
    
    enum Unit: String {
        case kg = "Kg", unit = "Uni.", liter = "L"
    }
    
    let _name: String
    let _amount: Int
    let _unit: Unit
    let _state: Bool
    let _description: String
    
    init (name: String, amount: Int, unit: Unit, description: String) {
        self._name = name
        self._amount = amount
        self._unit = unit
        self._description = description
        self._state = false
    }
    
}

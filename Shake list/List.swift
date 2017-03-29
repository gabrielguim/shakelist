//
//  List.swift
//  Shake list
//
//  Created by Student on 3/21/17.
//  Copyright © 2017 Student. All rights reserved.
//

import Foundation


class List {
    
    let _name: String
    var _items: [Item]
    var _creationDate: Date
    var _usersList: [User]
    var _majorUser: String
    
    init (name: String, major: String) {
        self._name = name
        self._items = [Item]()
        self._creationDate = Date()
        self._usersList = [User]()
        self._majorUser = major
    }
    
}

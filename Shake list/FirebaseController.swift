//
//  FirebaseController.swift
//  Shake list
//
//  Created by Student on 3/22/17.
//  Copyright © 2017 Student. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

class FirebaseController {
    
    static let lists: String = "lists"
    static let users: String = "users"
    static let items: String = "items"
    
    static let ref = FIRDatabase.database().reference(fromURL: "https://shake-a-list.firebaseio.com")
    
    static func save(list: List){
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        
        let listsRef = self.ref.child(lists).child(list._name)
    
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/MM/yyyy"
        let creationDate: String = dateFormatterPrint.string(from: list._creationDate)
        
        var itemsDict = [[String: AnyObject]]()
        var friendsDict = [[String: AnyObject]]()
        
        for item in list._items {
            let itemDict = [
                "name": item._name,
                "description": item._description,
                "amount": item._amount,
                "state": item._state,
                "unit": item._unit
                ] as [String : Any]
            
            itemsDict.append(itemDict as [String : AnyObject])
        }
        
        for user in list._friendsList {
            let userDict = [
                "name": user._name,
                "email": user._email
            ]
            
            friendsDict.append(userDict as [String : AnyObject])
        }
        
        let dict: [String: AnyObject] = [
            "name": list._name as AnyObject,
            "date": creationDate as AnyObject,
            "items": itemsDict as AnyObject,
            "friendList": friendsDict as AnyObject
        ]
        
        listsRef.setValue(dict)
    }
    
    static func save(item: Item, on: List){
        FIRApp.configure()

        let listsRef = self.ref.child(lists).child(on._name).child(items).child(item._name)
        
        let itemDict = [
            "name": item._name,
            "description": item._description,
            "amount": item._amount,
            "state": item._state,
            "unit": item._unit
        ] as [String : Any]

        
        listsRef.setValue(itemDict)
    }
    
}

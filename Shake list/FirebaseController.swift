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
                "unit": item._unit.rawValue
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
    
    static func retrieveLists(_ completionHandler: @escaping ([List]) -> Void) {
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
  
        let listsRef = self.ref.child(lists)
        var allLists: [List] = [List]()
        
        listsRef.observe(.value, with: { snapshot in
            
            if !snapshot.exists() { return }
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                allLists = []
                
                for snap in snapshots {
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        
                        var list: List = List(name: snap.key)
                        
                        let dateFormatterPrint = DateFormatter()
                        dateFormatterPrint.dateFormat = "dd/MM/yyyy"
                        
                        if let data = postDictionary["date"] as? String {
                            let creationDate: Date = dateFormatterPrint.date(from: data)!
                            list._creationDate = creationDate
                        }
                        
                        list._items = []
                        

                        if let itemsDictionary = postDictionary["items"] as? Dictionary<String, AnyObject> {
                            
                            for item in itemsDictionary {
                                
                                if let currentItem = item.value as? Dictionary<String, AnyObject> {
                                    
                                    var unit = Item.Unit.kg
                                    
                                    if currentItem["unit"] as? String == Item.Unit.liter.rawValue {
                                        unit = Item.Unit.liter
                                    } else if currentItem["unit"] as? String == Item.Unit.unit.rawValue {
                                        unit = Item.Unit.unit
                                    }
                                    
                                    var newItem = Item(name: item.key, amount: currentItem["amount"] as! Int, unit: unit, description: (currentItem["description"] as? String)!)
                                    
                                    list._items.insert(newItem, at: 0)

                                }
                                
                            }
                        }
                        
                        allLists.append(list)
                    }
                    
                }
                
                completionHandler(allLists)
                
            }
            
        })
    }
    
    static func save(item: Item, on: List){
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }

        let listsRef = self.ref.child(lists).child(on._name).child(items).child(item._name)
        
        let itemDict = [
            "name": item._name,
            "description": item._description,
            "amount": item._amount,
            "state": item._state,
            "unit": item._unit.rawValue
        ] as [String : Any]

        
        listsRef.setValue(itemDict)
    }
    
}

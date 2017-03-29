
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
import FirebaseAuth

class FirebaseController {
    
    static let lists: String = "lists"
    static let users: String = "usersList"
    static let items: String = "items"
    
    static let ref = FIRDatabase.database().reference(fromURL: "https://shake-a-list.firebaseio.com")
    
    static func logoutUser(){
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        
        do {
            _ = try FIRAuth.auth()!.signOut()
        } catch _ {}
        
    }
    
    static func getCurrentUser() -> User {
        
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        
        var user: User?
    
        let email: String = (FIRAuth.auth()!.currentUser?.email)!
        
        user = User(email: email)
        
        return user!
    }
    
    static func checkLoggedUserState(delegate: LoginViewController) {
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            if user != nil {
                delegate.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
        
    }
    
    static func checkLoggedUser() -> Bool {
        
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        
        return FIRAuth.auth()!.currentUser != nil
    }
    
    static func registerUser(email: String, password: String) {
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { user, error in
            if error == nil {
                FIRAuth.auth()!.signIn(withEmail: email, password: password)
                self.createUser(email: email)
            }
        })
    }
    
    static func createUser(email: String) {
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        
        let newEmail = replaceCharacters(of: email)
        
        let usersRef = self.ref.child(users).child(newEmail)
        
        usersRef.setValue(email)

    }
    
    static func replaceCharacters(of: String) -> String {
        var newEmail = of.replacingOccurrences(of: "@", with: " at ")
        newEmail = newEmail.replacingOccurrences(of: ".", with: " dot ")
        
        return newEmail
    }
    
    static func loginUser(email: String, password: String, handler: @escaping FIRAuthResultCallback) {
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        
        FIRAuth.auth()!.signIn(withEmail: email, password: password, completion: handler)
        
    }
    
    static func save(list: List){
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        
        let listsRef = self.ref.child(lists).child(list._name)
    
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/MM/yyyy"
        let creationDate: String = dateFormatterPrint.string(from: list._creationDate)
        
        var itemsDict = [[String: AnyObject]]()
        var usersDict = [[String: AnyObject]]()
        
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
        
        for user in list._usersList {
            let userDict = [
                "email": user._email
            ] as [String: Any]
            
            usersDict.append(userDict as [String : AnyObject])
        }
        
        let dict: [String: AnyObject] = [
            "name": list._name as AnyObject,
            "date": creationDate as AnyObject,
            "items": itemsDict as AnyObject,
            "usersList": usersDict as AnyObject,
            "major": list._majorUser as AnyObject
        ]
        
        listsRef.setValue(dict)
        add(user: User(email: list._majorUser), on: list)
    }
    
    static func retrieveLists(email: String, handler completionHandler: @escaping ([List]) -> Void) {
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
                        
                        let majorUser = postDictionary["major"] as! String
                        let list: List = List(name: snap.key, major: majorUser)
                        
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
                                    
                                    let newItem = Item(name: item.key, amount: currentItem["amount"] as! Int, unit: unit, description: (currentItem["description"] as? String)!)
                                    
                                    newItem._state = currentItem["state"] as! Bool
                                    
                                    list._items.insert(newItem, at: 0)

                                }
                                
                            }
                        }
                        
                        
                        if let usersDictionary = postDictionary["usersList"] as? Dictionary<String, AnyObject> {
                            
                            for user in usersDictionary {
                                
                                let newUser = User(email: user.value as! String)
                                    
                                list._usersList.append(newUser)
                                    
                            }
                                
                        }
                        
                        
                        for currentUser in list._usersList {
                            if (currentUser._email == email){
                                allLists.append(list)
                            }
                        }

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
    
    static func check(item: Item, on: List) {
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        
        let listsRef = self.ref.child(lists).child(on._name).child(items).child(item._name).child("state")
        
        listsRef.setValue(item._state)
    }
    
    static func add(user: User, on: List) {
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        
        let email = replaceCharacters(of: user._email)
        
        let listsRef = self.ref.child(lists).child(on._name).child(users).child(email)
        
        listsRef.setValue(user._email)
    }
    
    static func retrieveList(list: List, handler completionHandler: @escaping (List) -> Void) {
        if (FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        
        let listsRef = self.ref.child(lists).child(list._name).child(items)
        let lista = List(name: list._name, major: list._majorUser)
        
        listsRef.observe(.value, with: { snapshot in
            
            if !snapshot.exists() { return }
            
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    var items: [Item] = []
                    lista._items = items
                    
                    for snap in snapshots {

                        if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                            var unit = Item.Unit.kg
                            
                            if postDictionary["unit"] as? String == Item.Unit.liter.rawValue {
                                unit = Item.Unit.liter
                            } else if postDictionary["unit"] as? String == Item.Unit.unit.rawValue {
                                unit = Item.Unit.unit
                            }
                            
                            let newItem = Item(name: postDictionary["name"] as! String, amount: postDictionary["amount"] as! Int, unit: unit, description: (postDictionary["description"] as? String)!)
                            
                            newItem._state = postDictionary["state"] as! Bool
                            
                            items.append(newItem)
                        }
                    }
                    
                    for item in items {
                        lista._items.append(item)
                    }
                    
                    completionHandler(lista)
                }
        })
    }
    
}

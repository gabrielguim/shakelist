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
    let _creationDate: Date
    var _friendsList: [User]
    
    init (name: String) {
        self._name = name
        self._items = [Item]()
        self._creationDate = Date()
        self._friendsList = [User]()
    }
    
}

class ListDAO {
    
    static var churrasco: List = List(name: "Churrasco")
    
    static var casamento: List = List(name: "Casamento")
    
    static var list: [List] = [churrasco, casamento]

    static var Churrasco = [
        Item(name: "Carne", amount: 10, unit: Item.Unit.kg, description: "Carne sem papelao"),
        Item(name: "Refrigerante", amount: 10, unit: Item.Unit.unit, description: "Pepsi pls"),
        Item(name: "Saco de Gelo", amount: 3, unit: Item.Unit.unit, description: "Gelado né?"),
        Item(name: "Farofa", amount: 1, unit: Item.Unit.kg, description: "Temperada")
    ]
    
    static var Casamento = [
        Item(name: "Cama", amount: 1, unit: Item.Unit.unit, description: "Cama de casal top"),
        Item(name: "Geladeira", amount: 1, unit: Item.Unit.unit, description: "Bastemp"),
        Item(name: "Fogāo", amount: 1, unit: Item.Unit.unit, description: "Ta pegando fogo, bicho!")
    ]
    
    
    static func getListaGeral() -> [List] {
        churrasco._items = getLista(titulo: "Churrasco")
        casamento._items = getLista(titulo: "Casamento")

        return list
    }
    
    static func addList(novaLista: List) {
        list.append(novaLista)
    }
    
    static func getLista(titulo: String) -> [Item] {
        
        var lista = [Item]()
        
        if (titulo == "Churrasco") {
            lista = Churrasco
        } else if (titulo == "Casamento"){
            lista = Casamento
        }
        
        return lista
        
    }
    
}

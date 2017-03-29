//
//  ItemTableViewCell.swift
//  Shake list
//
//  Created by Student on 3/21/17.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    var item: Item?
    var list: List?
    var delegate: ItemTableViewController?

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    @IBOutlet weak var checkBox: CheckBox!
    @IBAction func itemState(_ sender: Any) {
        self.item?._state = !checkBox.isChecked
        FirebaseController.check(item: item!, on: list!)
    }
    
    @IBAction func detail(_ sender: Any) {
    
        let refreshAlert = UIAlertController(title: "Descrição (\((item?._name)!))",
            message: item?._description, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in }))
    
        delegate?.present(refreshAlert, animated: true, completion: nil)
    
        
    }
    
}

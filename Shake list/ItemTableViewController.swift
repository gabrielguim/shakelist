//
//  ItemTableViewController.swift
//  Shake list
//
//  Created by Student on 3/21/17.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit
import DownPicker

class ItemTableViewController: UITableViewController {
    
    var alert: UIAlertController?
    var pickerData: [String] = [String]()
    var unitDownPicker: DownPicker!

    @IBOutlet weak var titleName: UILabel!
    
    @IBAction func listInfoButton(_ sender: Any) {
        
    }
    
    @IBAction func shareListButton(_ sender: Any) {
        alert = UIAlertController(title: "Compartilhar lista (\((self.list?._name)!))", message: "", preferredStyle: .alert)
        
        alert?.addTextField { (emailTextField) in
            emailTextField.placeholder = "E-mail"
        }
        
        alert?.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { (action: UIAlertAction!) in }))
        
        
        alert?.addAction(UIAlertAction(title: "Compartilhar", style: .default, handler: { [weak alert] (_) in
            let emailTextField = alert?.textFields![0]
            
            if !((emailTextField?.text?.isEmpty)!) {
                let user = User(email: (emailTextField?.text!)!)
                FirebaseController.add(user: user, on: self.list!)
            }
        }))
        
        alert?.textFields![0].addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        alert?.actions[1].isEnabled = false
        
        self.present(alert!, animated: true, completion: nil)
        
    }
    
    @IBAction func newItemButton(_ sender: Any) {
        
        alert = UIAlertController(title: "Criar item", message: "", preferredStyle: .alert)
        
        alert?.addTextField { (nameTextField) in
            nameTextField.placeholder = "Nome do item"
        }
        
        alert?.addTextField { (descriptionTextField) in
            descriptionTextField.placeholder = "Descriçāo"
        }
        
        alert?.addTextField { (amountTextField) in
            amountTextField.placeholder = "Qtd."
            amountTextField.keyboardType = UIKeyboardType.numberPad
        }
        
        alert?.addTextField{ (unitTextField) in
            self.pickerData = [Item.Unit.kg.rawValue, Item.Unit.liter.rawValue, Item.Unit.unit.rawValue]
            
            self.unitDownPicker = DownPicker(textField: unitTextField, withData: self.pickerData)
            self.unitDownPicker.setPlaceholder("Unidade")
        }
        
        alert?.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { (action: UIAlertAction!) in }))
        
        
        alert?.addAction(UIAlertAction(title: "Criar", style: .default, handler: { [weak alert] (_) in
            let nameTextField = alert?.textFields![0]
            let descriptionTextField = alert?.textFields![1]
            let amountTextField =  alert?.textFields![2]
            let unitTextField = self.unitDownPicker
            
            if !((nameTextField?.text?.isEmpty)! || (descriptionTextField?.text?.isEmpty)!
                || (amountTextField?.text?.isEmpty)! || (unitTextField?.text?.isEmpty)!) {
                
                var unit: Item.Unit
                
                switch ((unitTextField?.text)!) {
                    case "Kg": unit = Item.Unit.kg
                    case "L": unit = Item.Unit.liter
                    case "Uni.": unit = Item.Unit.unit
                    default: unit = Item.Unit.kg
                }
                
                let novoItem = Item(name: (nameTextField?.text)!, amount: Int((amountTextField?.text)!)!, unit: unit, description: (descriptionTextField?.text)!)
                
                FirebaseController.save(item: novoItem, on: (self.list)!)
                self.list?._items.append(novoItem)
                self.tableView.reloadData()
            }
            
        }))
        
        alert?.textFields![0].addTarget(self, action: #selector(self.textFieldDidChangeAll(_:)), for: .editingChanged)
        alert?.textFields![1].addTarget(self, action: #selector(self.textFieldDidChangeAll(_:)), for: .editingChanged)
        alert?.textFields![2].addTarget(self, action: #selector(self.textFieldDidChangeAll(_:)), for: .editingChanged)
        alert?.textFields![3].addTarget(self, action: #selector(self.textFieldDidChangeAll(_:)), for: .editingChanged)

        alert?.actions[1].isEnabled = false
        
        self.present(alert!, animated: true, completion: nil)
        
    }
    
    func isValidEmail(testEmail :String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testEmail)
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if (isValidEmail(testEmail: textField.text!)){
            alert?.actions[1].isEnabled = true
        } else {
            alert?.actions[1].isEnabled = false
        }
    }
    
    func textFieldDidChangeAll(_ textField: UITextField) {
        let nameTextField = alert?.textFields![0]
        let descriptionTextField = alert?.textFields![1]
        let amountTextField =  alert?.textFields![2]
        let unitTextField = self.unitDownPicker
        
        if !((nameTextField?.text?.isEmpty)! || (descriptionTextField?.text?.isEmpty)!
            || (amountTextField?.text?.isEmpty)! || (unitTextField?.text?.isEmpty)!) {
            alert?.actions[1].isEnabled = true
        } else {
            alert?.actions[1].isEnabled = false
        }
    }
    
    var list: List?

    override func viewDidLoad() {
        super.viewDidLoad()        
        self.titleName.text = self.list?._name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.list?._items.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemIdentifier", for: indexPath)

        // Configure the cell...
        if let itemCell = cell as? ItemTableViewCell {
            let currentItem = list?._items[indexPath.row]

            itemCell.amount.text = "\((String(describing: (currentItem?._amount)!))) \((currentItem?._unit.rawValue)!)"
            itemCell.name.text = currentItem?._name
            itemCell.checkBox.isChecked = (currentItem?._state)!
            
            itemCell.item = currentItem
            itemCell.delegate = self
            
        }

        return cell
    }
    
}

//
//  ItemTableViewController.swift
//  Shake list
//
//  Created by Student on 3/21/17.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit
import DownPicker
import SCLAlertView

class ItemTableViewController: UITableViewController {
    
    var shareAlert: SCLAlertView?
    var itemAlert: SCLAlertView?
    var pickerData: [String] = [String]()
    var unitDownPicker: DownPicker!
    
    // alert text fields
    var nameTextField: UITextField?
    var descriptionTextField: UITextField?
    var amountTextField: UITextField?
    var unitTextField: UITextField?
    var emailTextField: UITextField?
    var createButton: SCLButton?
    var shareButton: SCLButton?
    
    @IBOutlet weak var titleName: UILabel!
    
    @IBAction func shareListButton(_ sender: Any) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            showCircularIcon: false
        )
        
        shareAlert = SCLAlertView(appearance: appearance)
        emailTextField = shareAlert?.addTextField("E-mail")
        emailTextField?.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        emailTextField?.autocapitalizationType = .none
        
        shareButton = shareAlert?.addButton("Compartilhar") {
            if !((self.emailTextField?.text?.isEmpty)!) {
                let user = User(email: (self.emailTextField?.text!)!)
                FirebaseController.add(user: user, on: self.list!)
            }
        }
        
        shareAlert?.addButton("Cancelar") {}
        
        shareAlert?.showInfo("Compartilhar", subTitle: "Compartilhe sua lista!")
        
        shareButton?.isEnabled = false

    }
    
    @IBAction func newItemButton(_ sender: Any) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            showCircularIcon: false
        )
        
        itemAlert = SCLAlertView(appearance: appearance)
        
        
        nameTextField = itemAlert?.addTextField("Nome do item")
        nameTextField?.addTarget(self, action: #selector(self.textFieldDidChangeAll(_:)), for: .editingChanged)
        
        descriptionTextField = itemAlert?.addTextField("Descriçāo")
        descriptionTextField?.addTarget(self, action: #selector(self.textFieldDidChangeAll(_:)), for: .editingChanged)
        
        amountTextField = itemAlert?.addTextField("Qtd.")
        amountTextField?.keyboardType = UIKeyboardType.numberPad
        amountTextField?.addTarget(self, action: #selector(self.textFieldDidChangeAll(_:)), for: .editingChanged)
        
        unitTextField = itemAlert?.addTextField("Unidade")
        
        self.pickerData = [Item.Unit.kg.rawValue, Item.Unit.liter.rawValue, Item.Unit.unit.rawValue]
        self.unitDownPicker = DownPicker(textField: unitTextField, withData: self.pickerData)
        self.unitDownPicker.setPlaceholder("Unidade")
        self.unitDownPicker.addTarget(self, action: #selector(self.textFieldDidChangeAll(_:)), for: .valueChanged)
        
        createButton = itemAlert?.addButton("Adicionar") {
            
            if (!(self.nameTextField?.text?.isEmpty)! && !(self.descriptionTextField?.text?.isEmpty)! && !(self.amountTextField?.text?.isEmpty)! && self.unitDownPicker.selectedIndex != -1) {
                
                var unit: Item.Unit
                
                switch ((self.unitTextField?.text)!) {
                    case "Kg": unit = Item.Unit.kg
                    case "L": unit = Item.Unit.liter
                    case "Uni.": unit = Item.Unit.unit
                    default: unit = Item.Unit.kg
                }
                
                let novoItem = Item(name: (self.nameTextField?.text)!, amount: Int((self.amountTextField?.text)!)!, unit: unit, description: (self.descriptionTextField?.text)!)
                
                FirebaseController.save(item: novoItem, on: (self.list)!)
                self.list?._items.append(novoItem)
                self.tableView.reloadData()
            }

        }
        
        itemAlert?.addButton("Cancelar") {}
        
        itemAlert?.showInfo("Adicionar", subTitle: "Adicione item à sua lista")
        createButton?.isEnabled = false
        
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        if(emailTextField?.text?.isEmpty)!{
            emailTextField?.layer.borderColor = UIColor.red.cgColor
        } else {
            emailTextField?.layer.borderColor = UIColor.blue.cgColor
        }
        
        if !((emailTextField?.text?.isEmpty)!) {
            shareButton?.isEnabled = true
        } else {
            shareButton?.isEnabled = false
        }
    }
    
    func textFieldDidChangeAll(_ textField: UITextField) {
        
        if(nameTextField?.text?.isEmpty)!{
            nameTextField?.layer.borderColor = UIColor.red.cgColor
        } else {
            nameTextField?.layer.borderColor = UIColor.blue.cgColor
        }
        
        if(descriptionTextField?.text?.isEmpty)!{
            descriptionTextField?.layer.borderColor = UIColor.red.cgColor
        } else {
            descriptionTextField?.layer.borderColor = UIColor.blue.cgColor
        }
        
        if(unitTextField?.text?.isEmpty)!{
            unitTextField?.layer.borderColor = UIColor.red.cgColor
        } else {
            unitTextField?.layer.borderColor = UIColor.blue.cgColor
        }
        
        if(amountTextField?.text?.isEmpty)!{
            amountTextField?.layer.borderColor = UIColor.red.cgColor
        } else {
            amountTextField?.layer.borderColor = UIColor.blue.cgColor
        }
        
        if (!(nameTextField?.text?.isEmpty)! && !(descriptionTextField?.text?.isEmpty)! && !(amountTextField?.text?.isEmpty)! && self.unitDownPicker.selectedIndex != -1) {
            createButton?.isEnabled = true
        } else {
            createButton?.isEnabled = false
        }
    }
    
    func isValidEmail(testEmail :String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testEmail)
    }
    
    var list: List?

    override func viewDidLoad() {
        super.viewDidLoad()        
        self.titleName.text = self.list?._name
        
        FirebaseController.retrieveList(list: list!, handler: { (list) in
            self.list = list
            self.tableView.reloadData()
        })
        
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
            itemCell.list = self.list
            
        }

        return cell
    }
    
}

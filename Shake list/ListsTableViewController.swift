//
//  ListsTableViewController.swift
//  Shake list
//
//  Created by Student on 3/21/17.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit
import SCLAlertView

class ListsTableViewController: UITableViewController {
    
    var listAlert: SCLAlertView?
    var nameTextField: UITextField?
    var createButton: SCLButton?
    
    @IBAction func newListButton(_ sender: Any) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            showCircularIcon: false
        )
        
        listAlert = SCLAlertView(appearance: appearance)
        nameTextField = listAlert?.addTextField("Nome da lista")
        nameTextField?.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        createButton = listAlert?.addButton("Criar") {
            if !((self.nameTextField?.text?.isEmpty)!) {
                
                let novaLista = List(name: (self.nameTextField?.text)!, major: (self.currentUser?._email)!)
                
                FirebaseController.save(list: novaLista)
            }
        }
        
        listAlert?.addButton("Cancelar") {}
        
        listAlert?.showInfo("Criar", subTitle: "Crie sua lista!")
        
        createButton?.isEnabled = false

    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        if(nameTextField?.text?.isEmpty)!{
            nameTextField?.layer.borderColor = UIColor.red.cgColor
        } else {
            nameTextField?.layer.borderColor = UIColor.blue.cgColor
        }
        
        if (nameTextField?.text?.isEmpty)!{
            createButton?.isEnabled = false
        } else {
            createButton?.isEnabled = true
        }
    }
    
    var lists: [List]? = []
    var currentUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        if (currentUser == nil) {
            self.currentUser = FirebaseController.getCurrentUser()
        }
        
        FirebaseController.retrieveLists(email: (currentUser?._email)!, handler: { (lists) in
            self.lists = lists
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
        return (self.lists?.count)!
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listIdentifier", for: indexPath)

        // Configure the cell...
        if let itemList = cell as? ListTableViewCell {
            let currentItem = lists?[indexPath.row]
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd/MM/yyyy"
            let creationDate = dateFormatterPrint.string(from: (currentItem?._creationDate)!)
            
            itemList.name.text = currentItem?._name
            
            itemList.date.text = creationDate
            
            var itemString = "\(String(describing: (currentItem?._items.count)!)) item"
            
            if ((currentItem?._items.count)! > 1) {
                itemString = "\(String(describing: (currentItem?._items.count)!)) itens"
            } else if (currentItem?._items.count == 0) {
                itemString = "Sem itens por enquanto"
            }
            
            itemList.amount.text = itemString
            
            if ((currentItem?._usersList.count)! > 1){
                itemList.shared.image = UIImage(named: "ic_group")
            } else {
                itemList.shared.image = nil
            }
        }

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "listItemSegue" {
            
            if let novaView = segue.destination as? ItemTableViewController {
                
                if let indice = (tableView.indexPathForSelectedRow?.row) {
                    let listaSelecionada = self.lists?[indice]
                    
                    novaView.list = listaSelecionada
                }
                
            }
        }
    }

}

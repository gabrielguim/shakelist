//
//  ListsTableViewController.swift
//  Shake list
//
//  Created by Student on 3/21/17.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class ListsTableViewController: UITableViewController {
    
    var alert: UIAlertController?
    
    @IBAction func newListButton(_ sender: Any) {
        
        alert = UIAlertController(title: "Criar lista", message: "", preferredStyle: .alert)
        
        alert?.addTextField { (nameTextField) in
            nameTextField.placeholder = "Nome da lista"
        }
        
        alert?.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { (action: UIAlertAction!) in }))

        
        alert?.addAction(UIAlertAction(title: "Criar", style: .default, handler: { [weak alert] (_) in
            let nameTextField = alert?.textFields![0]
            
            if !((nameTextField?.text?.isEmpty)!) {
                let novaLista = List(name: (nameTextField?.text)!)
                
                FirebaseController.save(list: novaLista)
            }
            
        }))
        
        // Default values
        alert?.textFields![0].addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        alert?.actions[1].isEnabled = false
        
        self.present(alert!, animated: true, completion: nil)

    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if (textField.text == ""){
            alert?.actions[1].isEnabled = false
        } else {
            alert?.actions[1].isEnabled = true
        }
    }
    
    var lists: [List]? = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseController.retrieveLists { (lists) in
            self.lists = lists
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print((self.lists?.count)!)
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
            
            if (currentItem?._friendsList.count != 0){
                itemList.shared.image = UIImage(named: "ic_group")
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

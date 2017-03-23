//
//  ListsTableViewController.swift
//  Shake list
//
//  Created by Student on 3/21/17.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit

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
                self.tableView.reloadData()
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
    
    var list: [List] = ListDAO.getListaGeral()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listIdentifier", for: indexPath)

        // Configure the cell...
        if let itemList = cell as? ListTableViewCell {
            let currentItem = list[indexPath.row]
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd/MM/yyyy"
            let creationDate = dateFormatterPrint.string(from: currentItem._creationDate)
            
            itemList.name.text = currentItem._name
            itemList.date.text = creationDate
            
            var itemString = "\(String(currentItem._items.count)) item"
            
            if (currentItem._items.count > 1) {
                itemString = "\(String(currentItem._items.count)) itens"
            } else if (currentItem._items.count == 0) {
                itemString = "Sem itens por enquanto"
            }
            
            itemList.amount.text = itemString
            
            if (currentItem._friendsList.count != 0){
                itemList.shared.image = UIImage(named: "ic_group")
            }
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "listItemSegue" {
            
            if let novaView = segue.destination as? ItemTableViewController {
                
                if let indice = (tableView.indexPathForSelectedRow?.row) {
                    let listaSelecionada = self.list[indice]
                    
                    novaView.list = listaSelecionada
                }
                
            }
        }
    }

}

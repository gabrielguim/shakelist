    //
//  LoginViewController.swift
//  Shake list
//
//  Created by Student on 3/28/17.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    var alert: UIAlertController?
    
    @IBAction func registerButton(_ sender: Any) {
        
        alert = UIAlertController(title: "Registrar-se", message: "Insira e-mail e senha para se registrar", preferredStyle: .alert)
        
        alert?.addTextField { (emailTextField) in
            emailTextField.placeholder = "E-mail"
        }
        
        alert?.addTextField { (passwordTextField) in
            passwordTextField.placeholder = "Senha"
            passwordTextField.isSecureTextEntry = true
        }
        
        alert?.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { (action: UIAlertAction!) in }))
        
        
        alert?.addAction(UIAlertAction(title: "Registrar", style: .default, handler: { [weak alert] (_) in
            let emailTextField = alert?.textFields![0]
            let passwordTextField = alert?.textFields![1]
            
            if !((emailTextField?.text?.isEmpty)! && (passwordTextField?.text?.isEmpty)!) {
                FirebaseController.registerUser(email: (emailTextField?.text)!, password: (passwordTextField?.text)!)
            }
            
        }))
        
        alert?.textFields![0].addTarget(self, action: #selector(self.textFieldDidChangeAll(_:)), for: .editingChanged)
        alert?.textFields![1].addTarget(self, action: #selector(self.textFieldDidChangeAll(_:)), for: .editingChanged)
        
        alert?.actions[1].isEnabled = false
        
        self.present(alert!, animated: true, completion: nil)
    
    }
    
    func textFieldDidChangeAll(_ textField: UITextField) {
        let email = alert?.textFields![0]
        let password = alert?.textFields![1]
        
        if (isValidEmail(testEmail: (email?.text)!) && !((password?.text?.isEmpty)!) && (password?.text?.characters.count)! >= 6) {
            alert?.actions[1].isEnabled = true
        } else {
            alert?.actions[1].isEnabled = false
        }
    }
    
    @IBAction func signInButton(_ sender: Any) {
        let email = emailInput.text
        let password = passwordInput.text
        
        if isValidEmail(testEmail: email!) {
            
            FirebaseController.loginUser(email: email!, password: password!, handler: { (user, err) in
                if let error = err {
                    print(error.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            })
            
        } else {
            let refreshAlert = UIAlertController(title: "Erro ao efetuar login",
                message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in }))
            
            self.present(refreshAlert, animated: true, completion: nil)
        }
    
    }
    
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!

    func isValidEmail(testEmail :String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testEmail)
    }
    
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        FirebaseController.checkLoggedUserState(delegate: self)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loginSegue" {
            if let novaView = segue.destination as? ListsTableViewController {
                novaView.currentUser = User(email: emailInput.text!)
            }
        }
        
    }

}

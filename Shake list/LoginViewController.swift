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
import SCLAlertView

class LoginViewController: UIViewController {
    
    var registerAlert: SCLAlertView?
    var emailTextField: UITextField?
    var passwordTextField: UITextField?
    var registerButton: SCLButton?
    
    @IBAction func registerButton(_ sender: Any) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            showCircularIcon: false
        )
        
        registerAlert = SCLAlertView(appearance: appearance)
        emailTextField = registerAlert?.addTextField("E-mail")
        emailTextField?.keyboardType = .emailAddress
        emailTextField?.autocapitalizationType = .none
        emailTextField?.addTarget(self, action: #selector(self.textFieldDidChangeAll(_:)), for: .editingChanged)
        
        passwordTextField = registerAlert?.addTextField("Senha")
        passwordTextField?.isSecureTextEntry = true
        passwordTextField?.addTarget(self, action: #selector(self.textFieldDidChangeAll(_:)), for: .editingChanged)
        
        registerButton = registerAlert?.addButton("Registrar") {
            if !((self.emailTextField?.text?.isEmpty)! && (self.passwordTextField?.text?.isEmpty)!) {
                FirebaseController.registerUser(email: (self.emailTextField?.text)!, password: (self.passwordTextField?.text)!)
            }
        }
        
        registerAlert?.addButton("Cancelar") {}
        
        registerAlert?.showInfo("Registrar", subTitle: "Registre-se agora!")
        
        registerButton?.isEnabled = false
    
    }
    
    func textFieldDidChangeAll(_ textField: UITextField) {
        
        if !(isValidEmail(testEmail: (emailTextField?.text)!)) {
            emailTextField?.layer.borderColor = UIColor.red.cgColor
        } else {
            emailTextField?.layer.borderColor = UIColor.blue.cgColor
        }

        if ((passwordTextField?.text?.isEmpty)! || (passwordTextField?.text?.characters.count)! < 6){
            passwordTextField?.layer.borderColor = UIColor.red.cgColor
        } else {
            passwordTextField?.layer.borderColor = UIColor.blue.cgColor
        }
        
        if (isValidEmail(testEmail: (emailTextField?.text)!) && !((passwordTextField?.text?.isEmpty)!) && (passwordTextField?.text?.characters.count)! >= 6) {
            registerButton?.isEnabled = true
        } else {
            registerButton?.isEnabled = false
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
        
        emailInput?.keyboardType = .emailAddress
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

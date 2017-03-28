//
//  AccountViewController.swift
//  Shake list
//
//  Created by Student on 3/28/17.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    @IBAction func logoutButton(_ sender: Any) {
        
        FirebaseController.logoutUser()
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

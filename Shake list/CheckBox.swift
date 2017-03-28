//
//  CheckBox.swift
//  Shake list
//
//  Created by Student on 3/28/17.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit

class CheckBox: UIButton {

    let checkedImage = UIImage(named: "ic_check_box")! as UIImage
    let uncheckedImage = UIImage(named: "ic_check_box_outline")! as UIImage
    
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
            } else {
                self.setImage(uncheckedImage, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }
    
    func buttonClicked(sender: UIButton) {
        
        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = sender.transform.scaledBy(x: 0.5, y: 0.5)
        }) { (finished) in
            UIView.animate(withDuration: 0.2, animations: {
                sender.transform = sender.transform.scaledBy(x: 2, y: 2)
            })
        }
        
        if sender == self {
            self.isChecked = !self.isChecked
        }
    
    }
}

//
//  ChangePassword.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/22/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit

class ChangePassword: UIView {

    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnChangePasword: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var viewPassword: UIView!
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        viewPassword.layer.cornerRadius = 8;
        viewPassword.layer.masksToBounds = false;
        viewPassword.layer.shadowRadius = 3;
        viewPassword.layer.shadowOpacity = 0.5;
    }
 

}

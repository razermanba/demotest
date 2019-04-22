//
//  LoginViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/18/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

class LoginviewController : UIViewController{
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtUsername.text = UserDefaults.standard.string(forKey: "username")
        txtPassword.text = UserDefaults.standard.string(forKey: "password")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    @IBAction func actionKeep(_ sender: Any) {
        
    }
    
    @IBAction func actionForgorPassword(_ sender: Any) {
        
    }
    
    @IBAction func actionLogin(_ sender: Any) {
        loginUser(username: txtUsername.text!, password: txtPassword.text!)
        
    }
    
}


extension LoginviewController{
    func loginUser( username : String ,password : String ) {
        
        let param = ["username": username,
                     "password": password ] as [String : AnyObject]
        
        APIService.sharedInstance.login(param , completionHandle: { (result, error) in
            if error == nil {
                let user = Mapper<UserProfile>().map(JSONObject: result)
                UserDefaults.standard.set(user?.token, forKey: "token")
                
                APIService.sharedInstance.getProfile([:], completionHandle:  { (result, error) in
                    if error == nil{
                        let user = Mapper<UserProfile>().map(JSONObject: result)
                        
                        UserDefaults.standard.set(self.txtUsername.text!, forKey: "username")
                        UserDefaults.standard.set(self.txtPassword.text!, forKey: "password")
                        UserDefaults.standard.set(user?.room, forKey: "room")
                        UserDefaults.standard.set(user?.role, forKey: "role")
                        UserDefaults.standard.set(user?.id, forKey: "id")
                        UserDefaults.standard.set(user?.name, forKey: "name")
                        UserDefaults.standard.set(user?.username, forKey: "username")
                        UserDefaults.standard.set(user?.avatar, forKey: "avatar")
                        
                        
                        
                        if (user?.room)! > 0 {
                              self.performSegue(withIdentifier: "roomChat", sender: self)
                            
                        } else {
                            let alert = UIAlertController(title: "Warning", message: "You don't have any rooms", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                    }else {
                        let alert = UIAlertController(title: "Error", message: (error as! String), preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }else {
                let alert = UIAlertController(title: "Error", message: (error as! String), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    
}


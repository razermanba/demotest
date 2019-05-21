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

class LoginviewController : UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtVersion: UILabel!
    @IBOutlet weak var btnkeep: UIButton!
    
    var flagKeep : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        needsUpdate()
        
        txtUsername.text = UserDefaults.standard.string(forKey: "username")
        txtPassword.text = UserDefaults.standard.string(forKey: "password")
        
        let appVersion = String(format: "Version %@",(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!)
        txtVersion.text = appVersion
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let keeplogin = UserDefaults.standard.string(forKey: "keepLogin")
        if keeplogin == "true" && UserDefaults.standard.string(forKey: "username") != nil{
            btnkeep.setImage(UIImage(named: "border_ticked_signin"), for: UIControl.State.normal)
            loginUser(username: txtUsername.text!, password: txtPassword.text!)
        }else {
            UserDefaults.standard.set("false", forKey: "keepLogin")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func actionKeep(_ sender: Any) {
        if flagKeep == false{
            flagKeep = true;
            btnkeep.setImage(UIImage(named: "border_ticked_signin"), for: UIControl.State.normal)
            UserDefaults.standard.set("true", forKey: "keepLogin")
        }else {
            flagKeep = false;
            btnkeep.setImage(UIImage(named: "border_tick_signin"), for: UIControl.State.normal)
            UserDefaults.standard.set("false", forKey: "keepLogin")
        }
    }
    
    @IBAction func actionForgorPassword(_ sender: Any) {
        let alert = UIAlertController(title: "Warning", message: "Please contact your trainer", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func actionLogin(_ sender: Any) {
        loginUser(username: txtUsername.text!, password: txtPassword.text!)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}


extension LoginviewController{
    func loginUser( username : String ,password : String ) {
        
        let param = ["username": username,
                     "password": password ] as [String : AnyObject]
        
        APIService.sharedInstance.login(param , completionHandle: { (result, error) in
            if error == nil {
                let user = Mapper<UserProfile>().map(JSONObject: result)
                
                //                print(user?.token)
                UserDefaults.standard.set(user?.token, forKey: "token")
                
                let paramToken = ["device_id": UIDevice.current.identifierForVendor!.uuidString,
                                  "device_token":UserDefaults.standard.string(forKey: "device_token"),
                                  "device_type": "ios"] as [String : AnyObject]
                
                APIService.sharedInstance.submitDeviceToken(paramToken, completionHandle: { (result, error) in
                    
                })
                
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
    
    func needsUpdate() {
        let infoDictionary = Bundle.main.infoDictionary
        let appID = infoDictionary!["CFBundleIdentifier"] as! String
        let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)")
        guard let data = try? Data(contentsOf: url!) else {
            print("There is an error!")
            return 
        }
        let lookup = (try? JSONSerialization.jsonObject(with: data , options: [])) as? [String: Any]
        if let resultCount = lookup!["resultCount"] as? Int, resultCount == 1 {
            if let results = lookup!["results"] as? [[String:Any]] {
                if let appStoreVersion = results[0]["version"] as? String{
                    let currentVersion = infoDictionary!["CFBundleShortVersionString"] as? String
                    if !(appStoreVersion == currentVersion) {
                        print("Need to update [\(appStoreVersion) != \(String(describing: currentVersion))]")
                    }else {
                        let alert = UIAlertController(title: "Announcement", message: "Please update new version \(String(describing: currentVersion))", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ action -> Void in
                            guard let url = URL(string: "itms://itunes.apple.com/us/app/personal-brain-coach/id1244995154?ls=1&mt=8") else { return }
                            UIApplication.shared.open(url)
                        })
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
}


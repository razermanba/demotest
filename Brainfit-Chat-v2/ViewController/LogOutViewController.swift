//
//  LoginOutViewController.swift
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
import SocketIO


class LogOutViewController: UIViewController {
     let appdelgate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let alertController = UIAlertController(title: "Alert", message: "Are you sure ?", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Logout", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.logoutUser()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            self.tabBarController?.selectedIndex = 0
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)

    }

}


extension LogOutViewController{
    func logoutUser() {
        APIService.sharedInstance.logOutUser([:], completionHandle: { (result, error) in
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "password")
            UserDefaults.standard.removeObject(forKey: "token")
            UserDefaults.standard.removeObject(forKey: "room")
            UserDefaults.standard.removeObject(forKey: "role")
            UserDefaults.standard.removeObject(forKey: "id")
            UserDefaults.standard.removeObject(forKey: "name")
            UserDefaults.standard.removeObject(forKey: "avatar")
            
            SocketIOManager.sharedInstance.socketDisconnect()
//            self.performSegue(withIdentifier: "logOut", sender: self)
            var controller: UINavigationController
            controller = self.storyboard?.instantiateViewController(withIdentifier: "NavigationStoryboard") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
            
        })
    }
}

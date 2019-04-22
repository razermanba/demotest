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


class LogOutViewController: UIViewController {
    override func viewDidLoad() {
        super .viewDidLoad()
        
        logoutUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}


extension LogOutViewController{
    func logoutUser() {
        APIService.sharedInstance.logOutUser([:], completionHandle: { (result, error) in
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "password")
            UserDefaults.standard.removeObject(forKey: "token")
//            self.performSegue(withIdentifier: "logOut", sender: self)
            var controller: UINavigationController
            controller = self.storyboard?.instantiateViewController(withIdentifier: "NavigationStoryboard") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
            
        })
    }
}

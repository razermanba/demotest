//
//  TabBarViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 5/21/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.tabBar.tintColor = UIColor.white
        self.tabBar.unselectedItemTintColor = UIColor.white
        let role = UserDefaults.standard.value(forKey: "role") as! String
        if role == "student" {
            self.viewControllers?.remove(at: 1)
        }
        

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

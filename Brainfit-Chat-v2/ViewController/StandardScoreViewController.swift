//
//  StandardScoreViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 5/20/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper


class StandardScoreViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStandardScore()
        // Do any additional setup after loading the view.
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

extension StandardScoreViewController {
    func loadStandardScore(){
        
        APIService.sharedInstance.getStandardScore([:], user_id: String(format: "%@", UserDefaults.standard.value(forKey: "id")  as! CVarArg), completionHandle: {(result, error) in
            let standardScore = Mapper<StandardScore>().map(JSONObject: result)
            print(standardScore)
        })
    }
}

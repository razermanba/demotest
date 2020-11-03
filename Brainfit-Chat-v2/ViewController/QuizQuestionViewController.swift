//
//  QuizQuestionViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 11/3/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit

class QuizQuestionViewController: UIViewController {

    @IBOutlet weak var questionTableView: UITableView!
    
    var arrQuestion = ["Q1.lorem ipsum dolor sitmet","Q2.lorem ipsum dolor sitmet"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.questionTableView.estimatedRowHeight = 150
        self.questionTableView.rowHeight = UITableView.automaticDimension

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


extension QuizQuestionViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrQuestion.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cellQuestion", for: indexPath) as! QuizQuestionTableViewCell
        cell.lblQuestion.text = arrQuestion[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
    
}

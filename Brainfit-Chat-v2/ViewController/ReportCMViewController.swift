//
//  ReportCMViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 5/20/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit

class ReportCMViewController: UIViewController {

//    var viewHeader = ViewHeader()
    
    @IBOutlet weak var viewAddSub: UIView!
    var StandardScore : StandardScoreViewController!
//    var PollVC : PollUserViewController!
    
    var oldVC : UIViewController!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        standardScoreVC()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func studentPorgress(_ sender: Any) {
    
    }
    
    @IBAction func standardScore(_ sender: Any) {
        standardScoreVC()
    }
    
    
}

extension ReportCMViewController{
    func standardScoreVC() {
        self.removeChildViewController()
        oldVC = self.StandardScoreController()
        self.activeChildViewController(oldVC)
        animateViewHeight(oldVC.view, withAnimationType: CATransitionSubtype.fromTop.rawValue, andflagClose: true)
    }

    //remove room
    func removeChildViewController() {
        if (oldVC != nil) {
            oldVC.willMove(toParent: nil)
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParent()
        }
    }
    
    func activeChildViewController(_ activeVC: UIViewController) {
        addChild(activeVC)
        activeVC.view.frame = CGRect(x: 0, y: 0, width:viewAddSub.frame.width, height: viewAddSub.frame.size.height)
        viewAddSub.addSubview(activeVC.view)
        activeVC.didMove(toParent: self)
    }
    
    func StandardScoreController() -> StandardScoreViewController {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        StandardScore = storyboard.instantiateViewController(withIdentifier: "StandardScoreStoryboardID") as? StandardScoreViewController
        addChild(StandardScore);
        StandardScore.didMove(toParent: self)
        
        return StandardScore
    }
    
    // MARK: - animate view
    func animateViewHeight(_ animateView: UIView, withAnimationType animType: String, andflagClose flag: Bool) {
        let animation = CATransition()
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype(rawValue: animType)
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animateView.layer.add(animation, forKey: kCATransition)
        //        animateView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:0.9)
        if flag == false {
            animateView.isHidden = !animateView.isHidden
        }
    }

    
}

//
//  ListTokenViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/22/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import AlamofireImage
import SDWebImage

class ListTokenViewController: UIViewController {
    
    @IBOutlet weak var lblTotalCount: UILabel!
    @IBOutlet weak var TokenTable: UITableView!
    
    var tokenview = alertToken()
    
    var arrayToken = Mapper<Tokens>().mapArray(JSONArray: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image : UIImage = UIImage(named: "logo_groupchat.png")!
        let imageView = UIImageView()
        imageView.frame.size.width = 40
        imageView.frame.size.height = 40
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        navigationItem.titleView = imageView
        
        
        lblTotalCount.text = String(format: "%d", arrayToken.count)
        
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

extension ListTokenViewController : UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayToken.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tokenCell", for: indexPath) as! ListTokenTableViewCell
        let url = URL(string: (self.arrayToken[indexPath.row].image)!)!
        DispatchQueue.main.async {
            cell.imageToken.sd_setAnimationImages(with: [url])
        }
        
        cell.lblName.text = self.arrayToken[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let window = UIApplication.shared.keyWindow!
        tokenview = (Bundle.main.loadNibNamed("alertToken", owner: self, options: nil)?.first as? alertToken)!
        tokenview.bounds = window.bounds
        tokenview.center = window.center
        
        let url = URL(string: (self.arrayToken[indexPath.row].image)!)!
        tokenview.imageToken.sd_setAnimationImages(with: [url])
        
        tokenview.lblName.text = self.arrayToken[indexPath.row].name
        
        tokenview.btnClose.addTarget(self, action: #selector(self.actionClosePopUp), for: .touchUpInside)
        
        self.animateViewHeight(tokenview, withAnimationType: CATransitionSubtype.fromTop.rawValue, andflagClose: true)
        window.addSubview(tokenview)
    }
}

extension ListTokenViewController{
    
    func animateViewHeight(_ animateView: UIView, withAnimationType animType: String, andflagClose flag: Bool) {
        let animation = CATransition()
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype(rawValue: animType)
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animateView.layer.add(animation, forKey: kCATransition)
        if flag == false {
            animateView.isHidden = !animateView.isHidden
        }
    }
    
    
    @objc func actionClosePopUp() {
        self.animateViewHeight(tokenview, withAnimationType: CATransitionSubtype.fromBottom.rawValue, andflagClose: false)
    }
    
}

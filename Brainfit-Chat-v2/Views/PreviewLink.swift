//
//  PreviewLink.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/16/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit
import JGProgressHUD

class PreviewLink: UIView {
    
    @IBOutlet weak var urlTitle: UILabel!
    @IBOutlet weak var urlLink: UILabel!
    @IBOutlet weak var descriptionUrl: UILabel!
    @IBOutlet weak var imgUrl: UIImageView!
    let hud = JGProgressHUD(style: .dark)
    let indicator = UIActivityIndicatorView(style: .gray)
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    func loadImage(url : String){
        let urlImage = URL(string: url)
        let placeholderImage = UIImage(named: "avatar_student (1)")!
        imgUrl.sd_setImage(with: urlImage, placeholderImage: placeholderImage)
        
        
    }
    
    func showLoading(){
        //        hud.textLabel.text = "Loading"
        //        hud.show(in: self)
        
        indicator.center = self.center
        self.addSubview(indicator)
        indicator.startAnimating()
    }
    
    func dismissLoading(){
        //        hud.dismiss(afterDelay: 0.0)
        indicator.stopAnimating()
    }
    
    
}

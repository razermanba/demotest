//
//  DocumentViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 10/1/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit
import WebKit

class DocumentViewController: UIViewController ,UIWebViewDelegate {

    let appdelgate = UIApplication.shared.delegate as? AppDelegate
      
    @IBOutlet weak var viewWeb: UIWebView!
    var urlFile : URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image : UIImage = UIImage(named: "logo_groupchat.png")!
        let imageView = UIImageView()
        imageView.frame.size.width = 40
        imageView.frame.size.height = 40
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        navigationItem.titleView = imageView
        appdelgate?.showLoading()
        
        viewWeb.scalesPageToFit = true
        viewWeb.contentMode = .scaleToFill
//        let url: URL! = URL(string: urlFile ?? "")
        viewWeb.loadRequest(URLRequest(url: urlFile))
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        appdelgate?.dismissLoading()
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

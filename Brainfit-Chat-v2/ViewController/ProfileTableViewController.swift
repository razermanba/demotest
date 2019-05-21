//
//  ProfileTableViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/22/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageAvatar: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblName: UILabel!
    var changePWView = ChangePassword()
    var imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let image : UIImage = UIImage(named: "logo_groupchat.png")!
        let imageView = UIImageView()
        imageView.frame.size.width = 40
        imageView.frame.size.height = 40
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        navigationItem.titleView = imageView
        
        imageAvatar.layer.cornerRadius = imageAvatar.frame.width / 2
        imageAvatar.clipsToBounds = true

        let timestamp = "\(Date().timeIntervalSince1970 * 1000)"
        let url = URL(string: String(format: "%@?v=%@",UserDefaults.standard.value(forKey: "avatar")! as! String, timestamp))!
        imageAvatar.af_setImage(withURL:url )
        
        lblUsername.text = (UserDefaults.standard.value(forKey: "name") as! String)
        lblName.text =  (UserDefaults.standard.value(forKey: "username") as! String)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let window = UIApplication.shared.keyWindow!
            changePWView = (Bundle.main.loadNibNamed("ChangePassword", owner: self, options: nil)?.first as? ChangePassword)!
            changePWView.bounds = window.bounds
            changePWView.center = window.center
            
            changePWView.btnClose.addTarget(self, action: #selector(self.actionClosePopUp), for: .touchUpInside)
            changePWView.btnChangePasword.addTarget(self, action: #selector(self.actionChangePassword), for: .touchUpInside)
            
            
            self.animateViewHeight(changePWView, withAnimationType: CATransitionSubtype.fromTop.rawValue, andflagClose: true)
            window.addSubview(changePWView)
        }
    }
    
    @IBAction func changeAvatar(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
}


extension ProfileTableViewController{
    // MARK: - animate view
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
        self.animateViewHeight(changePWView, withAnimationType: CATransitionSubtype.fromBottom.rawValue, andflagClose: false)
    }
    
    @objc func actionChangePassword() {
        changePWView.txtNewPassword.resignFirstResponder()
        changePWView.txtConfirmPassword.resignFirstResponder()
        
        
        let param = ["password":changePWView.txtNewPassword.text,
                     "password_confirmation":changePWView.txtConfirmPassword.text] as [String : AnyObject]
        
        APIService.sharedInstance.changePassword(param, completionHandle: {(result, error) in
            self.animateViewHeight(self.changePWView, withAnimationType: CATransitionSubtype.fromBottom.rawValue, andflagClose: false)
            
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "password")
            UserDefaults.standard.removeObject(forKey: "token")
            
            var controller: UINavigationController
            controller = self.storyboard?.instantiateViewController(withIdentifier: "NavigationStoryboard") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
            
        })
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageAvatar.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.dismiss(animated: true, completion: { () -> Void in
            APIService.sharedInstance.uploadImage("", (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)! , completionHandle: {(result, error) in
                print(result as Any)
                let timestamp = "\(Date().timeIntervalSince1970 * 1000)"
                let url = URL(string: String(format: "%@?v=%@",UserDefaults.standard.value(forKey: "avatar")! as! String, timestamp))!
                self.imageAvatar.af_setImage(withURL:url )
            })
        })
    }
}

